import Constants from "../constants"

export const getDashboard = (user, socket) => {
    return (dispatch) => {
        const dashboard_channel = socket.channel(`dashboard:${user}`)

        dashboard_channel.on("remove_collection", payload => {
            dispatch({
                type: Constants.REMOVE_COLLECTION,
                payload: payload
            })
        })

        dashboard_channel.on("save_to_inbox", payload => {
            dispatch({
                type: Constants.SAVE_TO_INBOX,
                inbox_id: payload.inbox_id,
                payload: payload.data
            })
        })

        dashboard_channel.on("move_collection", payload => {
            dispatch({
                type: Constants.MOVE_COLLECTION,
                payload: {
                    collectionId: payload.collection_id, 
                    newIndex: payload.newIndex,
                    oldIndex: payload.oldIndex
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
            console.log("Create new collection")
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

export const createCollection = (channel, title) => {
    channel.push("create_collection", {
        title: title
    })
}

export const connectCollection = (socket, collection) => {
    return (dispatch) => {
        let channel = {}

        if (collection.hasOwnProperty("collection")) {
            channel = socket.channel(`collection:${collection.collection.id}`)

            channel.join().receive("ok", () => {
                dispatch({
                    type: Constants.ADD_COLLECTION_TO_DASHBOARD,
                    payload: {
                        data: collection,
                        channel: channel
                    }
                })
            })
        } else {
            channel = socket.channel(`collection:${collection.id}`)

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

const _actions = (channel) => {
    return (dispatch) => {
        channel.on("edit_collection", payload => {
            dispatch({
                type: Constants.EDIT_COLLECTION,
                payload: payload
            })
        })

        channel.on("edit_collection_notes", payload => {
            dispatch({
                type: Constants.EDIT_COLLECTION_NOTES,
                payload: payload
            })
        })

        channel.on("add_collection_note", payload => {
            dispatch({
                type: Constants.ADD_COLLECTION_NOTE,
                collection_id: payload.collection_id,
                payload: payload.payload
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

        channel.on("add_resource_note", payload => {
            dispatch({
                type: Constants.ADD_RESOURCE_NOTE,
                collection_id: payload.collection_id,
                resource_id: payload.resource_id,
                payload: payload.payload
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

export const moveCollection = (channel, collection_id, new_index, old_index) => {
    return (dispatch) => {
        channel.push("move_collection", {
            collection_id: parseInt(collection_id),
            newIndex: parseInt(new_index),
            oldIndex: parseInt(old_index)
        })

        dispatch({
            type: Constants.MOVE_COLLECTION,
            payload: {
                newIndex: parseInt(new_index),
                oldIndex: parseInt(old_index)
            }
        })
    }
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

export const removeResource = (channel, collection_id, resource_id) => {
    channel.push("remove_resource", {
        collection_id: parseInt(collection_id),
        resource_id: parseInt(resource_id)
    })
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