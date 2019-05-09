import Constants from "../constants"

const initialState = {
    extensionsLoaded: false,
    files: [],
}

const extensions = (state = initialState, action) => {
    switch (action.type) {
    case Constants.ADD_EXTENSIONS:
        return {
            ...state,
            files: [
                ...state.files,
                ...action.payload
            ]
        }
    case Constants.ADD_COMPONENTS_TO_AREA:
        var keys = Object.keys(action.payload)
        var extensionExists

        keys.map(key => {
            if (state[key]) {
                extensionExists = key
            }
        })
        
        if (extensionExists) {
            return {...state, [extensionExists]: state[extensionExists].concat(action.payload[extensionExists])}
        }
        
        return {...state, ...action.payload}
    case Constants.EXTENTIONS_LOADED:
        return {
            ...state,
            extensionsLoaded: true
        }
    default:
        return state
    }
}

export default extensions