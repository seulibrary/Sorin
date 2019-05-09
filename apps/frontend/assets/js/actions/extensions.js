import Constants from "../constants"

export const addExtensions = (payload) => {
    return (dispatch) => {
        dispatch({
            type: Constants.ADD_EXTENSIONS,
            payload: payload
        })
    }
}

export const addComponentsToArea = (payload) => {
    return (dispatch) => {
        dispatch(
            {type: Constants.ADD_COMPONENTS_TO_AREA,
                payload: payload
            })
    }
}

export const showExtension = (component) => {
    return (dispatch) => {
        dispatch(
            {type: Constants.SHOW_EXTENSION,
                payload: { component }
            })
    }
}

export const extensionsLoaded = () => {
    return (dispatch) => {
        dispatch(
            {type: Constants.EXTENTIONS_LOADED}
        )
    }
}
