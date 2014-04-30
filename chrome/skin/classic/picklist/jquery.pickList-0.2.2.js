/*
 * jQuery PickList 0.2.2
 *
 * http://code.google.com/p/jquery-picklist/
 *
 * Copyright (c) 2010 GengWei
 *
 * Licensed under the Apache License, Version 2.0:
 *   http://www.opensource.org/licenses/apache2.0.php
 */

$(function(){
	
	function PickList(options) {
		this.options = {};
		$.extend(this.options, this.defaults, options);
		
		this.context = this.options.context;
		
		var ctx = this.context;	
		
		this.availableList = $(this.options.availableList_selector, ctx);
		this.pickedList = $(this.options.pickedList_selector, ctx);
		this.addButton = $(this.options.addButton_selector, ctx);
		this.removeButton = $(this.options.removeButton_selector, ctx);
		
		this.init();
	}
	
	PickList.prototype = {
		defaults: {
			context: "body",
			availableList_selector : "#availableList",
			pickedList_selector : "#pickedList",
			item_selector : "li",
			addButton_selector : "#btnAdd",
			removeButton_selector : "#btnRemove",
			selectedItemClassName : "selectedItem",
			hoverItemClassName : "hoverItem"
		},
		setDefaults: function(options) {
			$.extend(this.defaults, options);
		},
		init: function() {
			var opt = this.options;
			this.initList(this.availableList);
			this.initList(this.pickedList);
			
			var that = this;
			
			this.addButton.click(function(){
				that.addButtonClicked();
			});
			
			this.removeButton.click(function(){
				that.removeButtonClicked();
			});
		},
		initList: function(list) {
			var opt = this.options;
						
			list.click(function(event){
				var item = $(event.target);
				
				// 如果item不是PickItem（很可能是事件冒泡的PickItem的后代元素），则将item设为该PickItem
				if(!item.is(opt.item_selector)) {
					item = item.parents(opt.item_selector).eq(0);
				}
								
				var allItems = list.find(opt.item_selector);
				
				// 如果按住CTRL键，则交换选择状态；如果没有按CTRL键，则取消其他选中项
				if(event.ctrlKey) {
					item.toggleClass(opt.selectedItemClassName);
				} else {
					allItems.removeClass(opt.selectedItemClassName);
					item.addClass(opt.selectedItemClassName);
				}
					
				// 如果按住Shift键，则选择当前选择与上次选择之间的所有项
				if(event.shiftKey) {
					var lastClickedItem = list.lastClickedItem;
					if(lastClickedItem) {				
						var lastClickedItemIndex = allItems.index(lastClickedItem);
						var clickedItemIndex = allItems.index(item);
						
						var startIndex = Math.min(lastClickedItemIndex, clickedItemIndex);
						var endIndex = Math.max(lastClickedItemIndex, clickedItemIndex);
							
						for(i=startIndex; i<=endIndex; i++) {
							allItems.eq(i).addClass(opt.selectedItemClassName);
						}
					}
				}
				
				list.lastClickedItem = item;
					
				return false;
				
			}).mouseover(function(event){
				var item = $(event.target);
				
				// 如果item不是PickItem（很可能是事件冒泡的PickItem的后代元素），则将item设为该PickItem
				if(!item.is(opt.item_selector)) {
					item = item.parents(opt.item_selector).eq(0);
				}
												
				item && item.addClass(opt.hoverItemClassName);
				
				if($(this).is(opt.availableList_selector)) {
					opt.hoverOverAvailableItem && opt.hoverOverAvailableItem();
				} else if($(this).is(opt.pickedList)) {
					opt.hoverOverPickedItem && opt.hoverOverPickedItem();
				}
				
				return false;
			}).mouseout(function(event){
				var item = $(event.target);				
				
				// 如果item不是PickItem（很可能是事件冒泡的PickItem的后代元素），则将item设为该PickItem
				if(!item.is(opt.item_selector)) {
					item = item.parents(opt.item_selector).eq(0);
				}
												
				item && item.removeClass(opt.hoverItemClassName);
				
				if($(this).is(opt.availableList_selector)) {
					opt.hoverOutAvailableItem && opt.hoverOutAvailableItem();
				} else if($(this).is(opt.pickedList)) {
					opt.hoverOutPickedItem && opt.hoverOutPickedItem();
				}
				
				return false;
			});
						
		},
		containsItem : function(toList, item) {
			var existedItem = null;
			var item_id = parseInt($.trim(item.find(".idCol").text()), 10);
				
			toList.find(".idCol").each(function(i){
				if(parseInt($.trim($(this).text()), 10) === item_id) {
					existedItem = $(this);
					return false;
				}
			});
		
			return existedItem;
		},
		moveItems: function(fromList, toList, beforeMove, afterMove) {
			var opt = this.options;
			var toBeMovedItems = fromList.find("." + opt.selectedItemClassName);
			
			if(toBeMovedItems.size()>0) {
				
				// 如果beforeMove不为空，且返回false，则不移动选中的项目
				if(beforeMove && beforeMove(this) === false) {
					return false;
				}
				
				var that = this;
						
				toBeMovedItems.remove().each(function(i){
					var existedItem = that.containsItem && that.containsItem(toList, $(this));
					if(existedItem) {
						existedItem.closest(opt.item_selector).addClass(opt.selectedItemClassName);
					} else {
						toList.append($(this));
					}
				});
				
				fromList.lastClickedItem = null;
								
				// 执行afterMove
				afterMove && afterMove(this);
			}
		},
		addButtonClicked: function() {
			this.moveItems(this.availableList, this.pickedList, this.options.beforeAdd, this.options.afterAdd);
			return false;
		},		
		removeButtonClicked: function() {
			this.moveItems(this.pickedList, this.availableList);
			return false;
		},
		getPickedItems: function() {
			return this.pickedList.find(this.options.item_selector);
		},
		getAvailableItems: function() {
			return this.availableList.find(this.options.item_selector);
		},
		getSelectedPickedItems: function() {
			return this.pickedList.find("." + this.options.selectedItemClassName);
		},
		getSelectedAvailableItems: function() {
			return this.availableList.find("." + this.options.selectedItemClassName);
		},
		getLastClickedAvailableItem: function() {
			return this.availableList.lastClickedItem;
		},
		getLastClickedPickedItem: function() {
			return this.pickedItem.lastClickedItem;
		},
		clearPickedList: function() {
			this.pickedList.empty();
			this.pickedList.lastClickedItem = null;
			return this;
		},
		clearAvailableList: function() {
			this.availableList.empty();
			this.availableList.lastClickedItem = null;
			return this;
		},
		insertAvailableItems: function(html) {
			this.availableList.append(html);
			return this;
		},
		insertPickedItems: function(html) {
			this.pickedList.append(html);
			return this;
		}
		
	};
	
	$.extend({
		pickList: function(options) {
			return new PickList(options);
		}
	});
	
	$.pickList.setDefaults = function(options) {
		$.extend(PickList.prototype.defaults, options);
	};
	
	$.pickList.prototype = PickList.prototype;
	
	$.fn.extend({
		pickList: function(options) {
			$.extend(options, {
				context: $(this)
			});
			return new PickList(options);
		}
	});
	
	
});