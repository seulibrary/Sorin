import { Presence } from "../../../../../deps/phoenix"
import Constants from "../constants"
import { handleActions, createAction } from 'redux-actions'
import _ from "lodash"

export const setPresence = createAction('PRESENCE/SET')
export const presenceDiff = createAction('PRESENCE/DIFF')

// Connect to the users dashboard, connect to each collection in the dashbaord. 
// Setup up channel event listeners for various actions like editing.

export const getDashboard = (user, socket) => {
    return (dispatch) => {
        const dashboard_channel = socket.channel(`dashboard:${user}`)

        dashboard_channel.on("remove_collection", payload => {
            dispatch({
                type: Constants.REMOVE_COLLECTION,
                payload: payload
            })
        })

        dashboard_channel.on("move_collection", payload => {
            dispatch({
                type: Constants.MOVE_COLLECTION,
                payload: {
                    collection_id: parseInt(payload.collection_id), 
                    new_index: parseInt(payload.new_index),
                    old_index: parseInt(payload.old_index)
                }
           })
        })

        dashboard_channel.on("move_resource", payload => {
            dispatch({
                type: Constants.MOVE_RESOURCE,
                payload: {
                    source_collection_id: parseInt(payload.source_collection_id),
                    target_collection_id: parseInt(payload.target_collection_id),
                    resource_id: parseInt(payload.resource_id),
                    index: parseInt(payload.target_index)
                }
            })
        })

        dashboard_channel.on("clone_collection", payload => {
            dispatch(
                connectCollection(socket, payload)
            )
        })

        dashboard_channel.on("import_collection", payload => {
            dispatch(
                connectCollection(socket, payload)
            )
        })

        dashboard_channel.on("add_collection_to_dashboard", payload => {
            dispatch(
                connectCollection(socket, payload)
            )
        })

        dashboard_channel.join().receive("ok", (json) => {
            dispatch({
                type: Constants.GETTING_DASHBOARD
            })

            dispatch({
                type: Constants.SETTING_UP_DASHBOARD,
                dashboardChannel: dashboard_channel
            })

            for (var i = 0; i < json.data.length; i++) {
                const data = json.data[i]

                // find and set inbox id
                if (data.index === 0) {
                    dispatch({
                        type: Constants.SET_INBOX_ID,
                        inbox_id: data.collection.id
                    })
                    
                    
                }
                // Connect to each collection
                dispatch(connectCollection(socket, data))
            }

            dispatch({
                type: Constants.GOT_DASHBOARD
            })
        }).receive("error", resp => {
            console.log("Unable to join", resp)
        })
    }
}

export const connectCollection = (socket, collection) => {
    return (dispatch) => {
        let channel = {}

        if (collection.hasOwnProperty("collection")) {
            channel = socket.channel(`collection:${collection.collection.id}`)

            channel.on("presence_state", state => {
                dispatch(setPresence(state))
            })

            channel.on("presence_diff", diff => {
                dispatch(presenceDiff(diff))
            })


            channel.join().receive("ok", () => {
                dispatch({
                    type: Constants.ADD_COLLECTION_TO_DASHBOARD,
                    payload: {
                        data: collection,
                        channel: channel
                    }
                })
                
                if (collection.index === 0) {
                    // See if there are any resrouce cookies that need to be saved
                    // only do it for inbox (index 0)
                    checkForResourceCookies(channel, collection.collection.id)
                }
                
            })
        } else {
            channel = socket.channel(`collection:${collection.id}`)
            channel.on("presence_state", state => {
                dispatch(setPresence(state))
            })

            channel.on("presence_diff", diff => {
                dispatch(presenceDiff(diff))
            })

            channel.join().receive("ok", () => {
                dispatch({
                    type: Constants.ADD_COLLECTION_TO_DASHBOARD,
                    payload: {
                        data: {
                            write_access: true,
                            pending_approval: false,
                            color: null,
                            collection: collection
                        },
                        channel: channel
                    }
                })
            })
        }

        dispatch(_actions(channel))
    }
}

// Current placeholder for presence tracking
let presences = {}

// List of listeners all collections need.
// Only actions like moving, creating, and deleting are used here.
const _actions = (channel) => {
    return (dispatch) => {
        
        channel.on("updated_collection", payload => {
            dispatch({
                type: Constants.EDIT_COLLECTION,
                payload: payload
            })
        })

        channel.on("updated_resource", payload => {
            dispatch({
                type: Constants.EDIT_RESOURCE,
                payload: payload
            })
        })

        channel.on("update_collection_notes", payload => {
            dispatch({
                type: Constants.UPDATE_COLLECTION_NOTES,
                ...payload
            })
        })

        channel.on("add_collection_tag", payload => {
            dispatch({
                type: Constants.ADD_COLLECTION_TAG,
                payload: payload
            })
        })

        channel.on("remove_collection_tag", payload => {
            dispatch({
                type: Constants.REMOVE_COLLECTION_TAG,
                payload: payload
            })
        })

        channel.on("add_resource", payload => {
            dispatch({
                type: Constants.ADD_RESOURCE,
                payload: payload
            })
        })

        channel.on("add_resource_by_index", payload => {
            dispatch({
                type: Constants.ADD_RESOURCE_BY_INDEX,
                payload: payload
            })
        })

        channel.on("update_resource_notes", payload => {
            dispatch({
                type: Constants.UPDATE_RESOURCE_NOTES,
                ...payload
            })
        })

        channel.on("remove_resource", payload => {
            dispatch({
                type: Constants.REMOVE_RESOURCE,
                payload: payload
            })
        })

        channel.on("file_uploaded", payload => {
            dispatch({
                type: Constants.FILE_UPLOAD,
                payload: payload
            })

            dispatch({
                type: Constants.FILE_RESET_STATUS
            })
        })

        channel.on("delete_file", payload => {
            dispatch({
                type: Constants.FILE_DELETE,
                payload: payload
            })

            dispatch({
                type: Constants.FILE_RESET_STATUS
            })
        })
    }
}

export const createCollection = (channel, title) => {
    channel.push("create_collection", {
        title: title
    })
}

export const updateCollectionNote = (channel, collection_id, note_id, content) => {
    return (dispatch) => {
        let id = note_id == "" || note_id == null ? null : note_id

        dispatch({
            type: Constants.UPDATE_COLLECTION_NOTES,
            collection_id: collection_id,
            note: {body: content, id: note_id}
        })

        channel.push("update_collection_notes", {
            collection_id: parseInt(collection_id),
            note_id: id,
            note: content
        })
    }
}

export const moveCollection = (channel, collection_id, new_index, old_index) => {
    return (dispatch) => {

        channel.push("move_collection", {
            collection_id: parseInt(collection_id),
            new_index: parseInt(new_index),
            old_index: parseInt(old_index)
        })

        dispatch({
            type: Constants.MOVE_COLLECTION,
            payload: {
                collection_id: parseInt(collection_id),
                new_index: parseInt(new_index),
                old_index: parseInt(old_index)
            }
        })
    }
}

export const cloneCollection = (channel, collection_id) => {
    channel.push("clone_collection", {
        collection_id: parseInt(collection_id)
    }).receive("error", () =>
        alert("Clone was unsuccessful. You may not have permission, or you already have this collection cloned.")
    )
}

export const importCollection = (channel, collection_id) => {
    channel.push("import_collection", {
        collection_id: parseInt(collection_id)
    }).receive("error", () => {
        alert("Import was not successful.")
    })
}

export const addCollectionTag = (channel, collection_id, label) => {
    channel.push("add_collection_tag", {
        collection_id: parseInt(collection_id),
        label: label
    })
}

export const deleteCollectionTag = (channel, collection_id, tag) => {
    channel.push("remove_collection_tag", {
        collection_id: parseInt(collection_id),
        tag: tag
    })
}

// On save, when not logged in. Save cookie.
export const saveResourceToCookie = (resource, login_state) => {
    window.localStorage.setItem(resource.title + "_sorin_resource", JSON.stringify(resource))
    window.location.href = "/auth/google?state=" + encodeURIComponent(login_state)
}

// After login, check for any cookies, save them as a resource, then delete them.
export const checkForResourceCookies = (channel, collection_id) => {
    _.forIn(window.localStorage, (value, objKey) => {
        if (true === _.endsWith(objKey, '_sorin_resource')) {
            createResource(channel, collection_id, JSON.parse(window.localStorage.getItem(objKey)))
        }
    });
    window.localStorage.clear()
}

export const createResource = (channel, collection_id, data) => {
    channel.push("create_resource", {
        collection_id: parseInt(collection_id),
        data: data
    })
}

export const editResource = (channel, collection_id, data) => {
    channel.push("edit_resource", {
        collection_id: parseInt(collection_id),
        data: data
    })
}

export const moveResource = (channel, resource_id, source_collection_id, target_collection_id, target_index) => {
    return (dispatch) => {
        channel.push("move_resource", {
            resource_id: parseInt(resource_id),
            source_collection_id: parseInt(source_collection_id),
            target_collection_id: parseInt(target_collection_id),
            target_index: parseInt(target_index)
        })

        dispatch({
            type: Constants.MOVE_RESOURCE,
            payload: {
                source_collection_id: parseInt(source_collection_id),
                target_collection_id: parseInt(target_collection_id),
                resource_id: parseInt(resource_id),
                index: parseInt(target_index)
            }
        })
    }
}

export const removeResource = (channel, collection_id, resource_id) => {
    channel.push("remove_resource", {
        collection_id: parseInt(collection_id),
        resource_id: parseInt(resource_id)
    })
}

export const updateResourceNote = (channel, collection_id, resource_id, note_id, content) => {
    return (dispatch) => {
        let id = note_id == "" || note_id == null ? null : note_id

        dispatch({
            type: Constants.UPDATE_RESOURCE_NOTES,
            collection_id: collection_id,
            resource_id: parseInt(resource_id),
            note: {body: content, id: note_id}
        })
        
        channel.push("update_resource_notes", {
            collection_id: parseInt(collection_id),
            resource_id: parseInt(resource_id),
            note_id: id,
            note: content
        })
    }
}