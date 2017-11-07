//
//  StateGenerator.swift
//  Client
//
//  Created by Tim Palade on 9/14/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//
//Definition of Transform
//tranform : (State, action) -> (State)
//this transform can be composed of smaller transforms
//transform = contentTransf + urlBarTransf + ToolTransf + ...

//The following dicts define the nextState for each currentState and ActionTyoe

let mainTransformDict: [ActionType : [MainState: MainState]] = [
    .initialization : [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    //.urlBackPressed : [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .urlClearPressed : [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .urlSearchPressed : [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .urlSearchTextChanged : [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .searchAutoSuggest: [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .searchStopEditing: [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .urlSelected: [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .urlIsModified: [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .homeButtonPressed: [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .tabsPressed: [.other: .tabsVisible, .reminderVisible: .tabsVisible, .actionSheetVisible: .tabsVisible],
    .sharePressed: [.other: .actionSheetVisible, .reminderVisible: .actionSheetVisible, .tabsVisible: .actionSheetVisible],
    .backButtonPressed: [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .forwardButtonPressed: [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other],
    .remindersPressed: [.other: .reminderVisible, .actionSheetVisible: .reminderVisible, .tabsVisible: .reminderVisible],
    .tabSelected: [.reminderVisible: .other, .actionSheetVisible: .other, .tabsVisible: .other]
]

//Attention: Actions are missing.
//New actions should always be included in the dicts here.

//the rule it this: If I ignore an action it means that the action does not affect the state of this component
//if I only define nextStates for subset of the states, then the action leaves the currentState as it is for the states that are not covered.
func contentNextState(actionType: ActionType, previousState: ContentState, currentState: ContentState, nextStateData: StateData) -> ContentState? {
    
    //this is for selecting an empty tab
    //think of a better way
    //maybe the tab should have a property isEmpty, and determine using that.
    var tabSelectedSpecialState: ContentState = .browse
    
    if nextStateData.tab?.url == nil {
        tabSelectedSpecialState = .domains
    }
    
    var tabDonePressedSpecialState: ContentState = currentState
    
    if let appDel = UIApplication.shared.delegate as? AppDelegate, let tabManager = appDel.tabManager {
        if currentState == .browse && tabManager.tabs.count == 0 {
            tabDonePressedSpecialState = .domains
        }
    }
    
    let contentTransformDict: [ActionType : [ContentState: ContentState]] = [
        .initialization : [.browse : .domains, .search: .domains, .domains: .domains, .details: .domains, .dash: .domains],
        //.urlBackPressed : [.search: previousState],
        .urlClearPressed : [.search: .search],
        .urlSearchPressed : [.browse: .search, .domains: .search, .details : .search, .dash: .search],
        .urlSearchTextChanged : [.browse: .search, .domains: .search, .details : .search, .dash: .search],
        .urlSelected : [.search : .browse, .domains: .browse, .details: .browse, .dash: .browse],
        .homeButtonPressed : [.browse : .domains, .search: .domains, .domains: .dash, .details: .domains, .dash: .domains],
        .tabSelected : [.search : tabSelectedSpecialState, .domains: tabSelectedSpecialState, .details: tabSelectedSpecialState, .dash: tabSelectedSpecialState, .browse: tabSelectedSpecialState],
        .detailBackPressed : [.details: .domains],
        .domainPressed : [.domains: .details],
        .tabDonePressed : [.browse : tabDonePressedSpecialState, .search: tabDonePressedSpecialState, .domains: tabDonePressedSpecialState, .details: tabDonePressedSpecialState, .dash: tabDonePressedSpecialState]
    ]
    
    if let actionDict = contentTransformDict[actionType], let nextState = actionDict[currentState] {
        return nextState
    }

    return nil
}

func urlBarNextState(actionType: ActionType, previousState: URLBarState, currentState: URLBarState, nextStateData: StateData) -> URLBarState? {
    
    let query = nextStateData.query ?? ""

    let queryEmpty: Bool = query == "" ? true : false

    let specialState: URLBarState = query != "" ? .expandedTextWhite : .expandedEmptyWhite

    //this is for selecting an empty tab
    var tabSelectedSpecialState: URLBarState = .collapsedDomainBlue

    if nextStateData.tab?.url == nil {
        tabSelectedSpecialState = .collapsedEmptyTransparent
    }
    
    var tabDonePressedSpecialState: URLBarState = currentState //The state does not change when the tabs are shown. So the state before opening the tabs is the current state
    
    if let appDel = UIApplication.shared.delegate as? AppDelegate, let tabManager = appDel.tabManager {
        if currentState == .collapsedDomainBlue && tabManager.tabs.count == 0 {
            tabDonePressedSpecialState = .collapsedEmptyTransparent
        }
    }
    
    let urlBarTransformDict: [ActionType: [URLBarState: URLBarState]] = [
        .initialization : [ .collapsedEmptyTransparent: .collapsedEmptyTransparent, .collapsedTextTransparent: .collapsedEmptyTransparent, .collapsedTextBlue: .collapsedEmptyTransparent, .collapsedDomainBlue: .collapsedEmptyTransparent, .expandedEmptyWhite: .collapsedEmptyTransparent, .expandedTextWhite: .collapsedEmptyTransparent],
        //.urlBackPressed : [ .collapsedEmptyTransparent: previousState, .collapsedTextTransparent: previousState, .collapsedTextBlue: previousState, .collapsedDomainBlue: previousState, .expandedEmptyWhite: previousState, .expandedTextWhite: previousState],
        .urlClearPressed : [.expandedTextWhite: .expandedEmptyWhite],
        .urlSearchPressed : [ .collapsedEmptyTransparent: specialState, .collapsedTextTransparent: specialState, .collapsedTextBlue: specialState, .collapsedDomainBlue: specialState],
        .urlSearchTextChanged : [.expandedTextWhite: queryEmpty ? .expandedEmptyWhite : .expandedTextWhite, .expandedEmptyWhite : .expandedTextWhite],
        .searchAutoSuggest: [ .collapsedEmptyTransparent: .expandedTextWhite, .collapsedTextTransparent: .expandedTextWhite, .collapsedTextBlue: .expandedTextWhite, .collapsedDomainBlue: .expandedTextWhite, .expandedEmptyWhite: .expandedTextWhite],
        //This is when user swipes up or down on the cards. I should change the state to collapsedSearch
        .searchStopEditing: [ .expandedEmptyWhite: .collapsedTextTransparent, .expandedTextWhite: .collapsedTextTransparent],
        .urlSelected: [ .collapsedEmptyTransparent: .collapsedDomainBlue, .collapsedTextTransparent: .collapsedDomainBlue, .expandedEmptyWhite: .collapsedDomainBlue, .expandedTextWhite: .collapsedDomainBlue],
        .urlIsModified: [.collapsedDomainBlue: .collapsedDomainBlue],
        .homeButtonPressed: [.collapsedTextTransparent: .collapsedEmptyTransparent, .collapsedDomainBlue: .collapsedEmptyTransparent ,.collapsedTextBlue: .collapsedEmptyTransparent, .expandedEmptyWhite: .collapsedEmptyTransparent, .expandedTextWhite: .collapsedEmptyTransparent],
        .tabSelected: [ .collapsedEmptyTransparent: tabSelectedSpecialState, .collapsedTextTransparent: tabSelectedSpecialState, .collapsedDomainBlue: tabSelectedSpecialState, .collapsedTextBlue: tabSelectedSpecialState, .expandedEmptyWhite: tabSelectedSpecialState, .expandedTextWhite: tabSelectedSpecialState],
        .detailBackPressed : [.collapsedTextTransparent: .collapsedEmptyTransparent, .collapsedDomainBlue: .collapsedEmptyTransparent, .collapsedTextBlue: .collapsedEmptyTransparent, .expandedEmptyWhite: .collapsedEmptyTransparent, .expandedTextWhite: .collapsedEmptyTransparent],
        .domainPressed : [.collapsedTextTransparent: .collapsedEmptyTransparent, .collapsedDomainBlue: .collapsedEmptyTransparent ,.collapsedTextBlue: .collapsedEmptyTransparent, .expandedEmptyWhite: .collapsedEmptyTransparent, .expandedTextWhite: .collapsedEmptyTransparent],
        .tabDonePressed : [ .collapsedEmptyTransparent: tabDonePressedSpecialState, .collapsedTextTransparent: tabDonePressedSpecialState, .collapsedTextBlue: tabDonePressedSpecialState, .collapsedDomainBlue: tabDonePressedSpecialState, .expandedEmptyWhite: tabDonePressedSpecialState, .expandedTextWhite: tabDonePressedSpecialState]
    ]
    
    if let actionDict = urlBarTransformDict[actionType], let newState = actionDict[currentState] {
        return newState
    }
    
    return nil
}

//TO DO: update dicts above to include all actions
final class ActionStateTransformer {
    //define possible states
    //define the possible transformations
    
    class func nextState(previousState: State, currentState: State, actionType: ActionType, nextStateData: StateData) -> State {
        
        
        //this makes sure you see a website when you change to another tab, even if you left from a search state on that tab
        if actionType == .tabSelected {
            if let tab = nextStateData.tab {
                if let (state, distance) = BackForwardNavigationHelper.firstContentStateBeforeCurrent(of: .browse, tab: tab) {
                    BackForwardNavigation.shared.decrementIndexByDistance(tab: tab, distance: distance)
                    return state
                }
                else if let (state, distance) = BackForwardNavigationHelper.firstContentStateAfterCurrent(of: .browse, tab: tab) {
                    BackForwardNavigation.shared.incrementIndexByDistance(tab: tab, distance: distance)
                    return state
                }
                else if let currentState_Tab = BackForwardNavigation.shared.currentState(tab: tab) {
                    return currentState_Tab
                }
            }
            else {
                //there should always be a tab coming in with this action
                NSException.init().raise()
            }
        }
        
        
        if let tab = currentState.stateData.tab {
            
            if actionType == .backButtonPressed {
                if BackForwardNavigation.shared.canWebViewGoBack(tab: tab) && currentState.contentState == .browse {
                    //if currentState.contentState == .browse, back and forward update correctly bacause of urlIsModified and urlProgressChanged
                    return currentState
                }
                else if var prevState = BackForwardNavigation.shared.prevState(tab: tab) {
                    BackForwardNavigation.shared.decrementIndex(tab: tab)
                    let back = toolBarBackTransform(nextStateData: prevState.stateData)
                    let forw = toolBarForwardTransform(nextStateData: prevState.stateData)
                    prevState = prevState.sameStateWithNewBackForwardState(newBackState: back, newForwardState: forw)
                    BackForwardNavigation.shared.replaceCurrentState(tab: tab, newState: prevState)
                    return prevState
                }
                else {
                    //there should be a prevState if the button can be pressed
                    NSException.init().raise()
                }
            }
            else if actionType == .forwardButtonPressed {
                if BackForwardNavigation.shared.canWebViewGoForward(tab: tab) && currentState.contentState == .browse {
                    //if currentState.contentState == .browse, back and forward update correctly bacause of urlIsModified and urlProgressChanged
                    return currentState
                }
                else if var nextState = BackForwardNavigation.shared.nextState(tab: tab) {
                    BackForwardNavigation.shared.incrementIndex(tab: tab)
                    let back = toolBarBackTransform(nextStateData: nextState.stateData)
                    let forw = toolBarForwardTransform(nextStateData: nextState.stateData)
                    nextState = nextState.sameStateWithNewBackForwardState(newBackState: back, newForwardState: forw)
                    BackForwardNavigation.shared.replaceCurrentState(tab: tab, newState: nextState)
                    return nextState
                }
                else {
                    //there should be a nextState if the button can be pressed
                    NSException.init().raise()
                }
            }
            else if actionType == .urlBackPressed {
                if var prevState = BackForwardNavigation.shared.prevState(tab: tab) {
                    BackForwardNavigation.shared.decrementIndex(tab: tab)
                    let back = toolBarBackTransform(nextStateData: prevState.stateData)
                    let forw = toolBarForwardTransform(nextStateData: prevState.stateData)
                    prevState = prevState.sameStateWithNewBackForwardState(newBackState: back, newForwardState: forw)
                    BackForwardNavigation.shared.replaceCurrentState(tab: tab, newState: prevState)
                    return prevState
                }
            }
        }
        
        
        return ActionStateTransformer.transform(previousState: previousState, currentState: currentState, actionType: actionType, nextStateData: nextStateData)
    }
    
    //this is the general transform
    private class func transform(previousState: State, currentState: State, actionType: ActionType, nextStateData: StateData) -> State {
        
        //The idea is that state data changes only when modified. If a url is not modified, then it remains like that. It is considered the last visited url.
        //The part about state data should be refactored.
        var alteredStateData = StateData.merge(lhs: nextStateData, rhs: currentState.stateData)
        
        //There should always be a tab selected. This makes sure that is true.
        if let appDel = UIApplication.shared.delegate as? AppDelegate, let tabManager = appDel.tabManager {
            if alteredStateData.tab == nil {
                let tab = tabManager.addTabAndSelect()
                let newStateData = StateData(query: nil, url: nil, tab: tab, detailsHost: nil, loadingProgress: nil)
                alteredStateData = StateData.merge(lhs: newStateData, rhs: alteredStateData)
            }
        }
	
		if currentState.urlBarState == .collapsedEmptyTransparent && actionType == .urlSearchPressed {
			let newStateData = StateData(query: "", url: nil, tab: nil, detailsHost: nil, loadingProgress: nil)
			alteredStateData = StateData.merge(lhs: newStateData, rhs: alteredStateData)
		}

        let mainNextState = mainContTransform(prevState: previousState.mainState, currentState: currentState.mainState, actionType: actionType)
        let contentNextState = contentNavTransform(previousState: previousState.contentState, currentState: currentState.contentState, nextStateData: alteredStateData, actionType: actionType)
        let urlBarNextState = urlBarTransform(prevState: previousState.urlBarState, currentState: currentState.urlBarState, nextStateData: alteredStateData, actionType: actionType)
        let toolBarNextState = toolBarTransform(currentState: currentState.toolBarState, actionType: actionType)
        let toolShareNextState = toolBarShareTransform(currentState: currentState.toolShareState, actionType: actionType)
        let toolForwardNextState: ToolBarForwardState = toolBarForwardTransform(nextStateData: alteredStateData)
        
        var state = State(mainState: mainNextState, contentState: contentNextState, urlBarState: urlBarNextState, toolBarState: toolBarNextState, toolBackState: .disabled, toolForwardState: toolForwardNextState, toolShareState: toolShareNextState, stateData: alteredStateData)
        
        //the status of the back button can be decided after the state is constructed
        if let tab = state.stateData.tab {
            //the back button status is decided here
            
            if actionType == .urlBackPressed {
                BackForwardNavigation.shared.decrementIndex(tab: tab)
            }
            
            let addOrReplace = BackForwardAddRule.addOrReplace(state: state, tab: tab, actionType: actionType)
            
            if BackForwardNavigation.shared.canGoBack(tab: tab) || addOrReplace == .add && actionType != .initialization {
                state = state.sameStateWithNewBackForwardState(newBackState: .enabled, newForwardState: state.toolForwardState)
            }
            
            if addOrReplace == .add {
                BackForwardNavigation.shared.addState(tab: tab, state: state)
            }
            else if addOrReplace == .replace {
                BackForwardNavigation.shared.replaceCurrentState(tab: tab, newState: state)
            }
            
        }
        
        return state
        
    }
    
    private class func mainContTransform(prevState: MainState, currentState: MainState, actionType: ActionType) -> MainState {
        var nextState = currentState
        
        if let actionDict = mainTransformDict[actionType], let newState = actionDict[currentState] {
            nextState = newState
        }
        
        return nextState
    }
    
    private class func contentNavTransform(previousState: ContentState, currentState: ContentState, nextStateData: StateData, actionType: ActionType) -> ContentState {
        
        if actionType == .urlProgressChanged || actionType == .urlIsModified {
            return currentState
        }
        
        var nextState = currentState
        
        if let newState = contentNextState(actionType: actionType, previousState: previousState, currentState: currentState, nextStateData: nextStateData) {
            nextState = newState
        }
        
        return nextState
    }
    
    private class func urlBarTransform(prevState: URLBarState, currentState: URLBarState, nextStateData: StateData, actionType: ActionType) -> URLBarState {
        var nextState = currentState
        
        if let newState = urlBarNextState(actionType: actionType, previousState: prevState, currentState: currentState, nextStateData: nextStateData) {
            nextState = newState
        }
        
        return nextState
    }
    
    //the toolBar's state should be set by the action .didChangeOrientation, but we don't have it here yet.
    private class func toolBarTransform(currentState: ToolBarState, actionType: ActionType) -> ToolBarState {
        return currentState
    }
    
    private class func toolBarBackTransform(nextStateData: StateData) -> ToolBarBackState {

        if let tab = nextStateData.tab {
            return BackForwardNavigation.shared.canGoBack(tab: tab) ? .enabled : .disabled
        }
        
        return .disabled
    }
    
    private class func toolBarForwardTransform(nextStateData: StateData) -> ToolBarForwardState {
        
        if let tab = nextStateData.tab {
            return BackForwardNavigation.shared.canGoForward(tab: tab) ? .enabled : .disabled
        }
        
        return .disabled
    }

    private class func toolBarShareTransform(currentState: ToolBarShareState, actionType: ActionType) -> ToolBarShareState {
        //this is currently handled by MainContainer.
        return currentState
    }
    
}
