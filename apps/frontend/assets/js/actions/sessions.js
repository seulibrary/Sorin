import Constants     from "../constants"  
import { Socket } from "../../../../../deps/phoenix"
import { getDashboard } from "../actions/collections"
import { checkForResourceCookies } from "./collections"


export function setCurrentUser() {
    return (dispatch) => {
        const socket = new Socket("/socket", {
            params: {
                token: window.userToken
            }
        })

        let userChannel = {}

        socket.connect()

        socket.onOpen(() => {
            userChannel = socket.channel("users:" + window.userToken)

            userChannel.join().receive("ok", () => {
                dispatch({
                    type: Constants.CURRENT_USER,
                    currentUser: null,
                    socket: socket,
                    channel: userChannel,
                })

                userChannel.push("joined")
            }).receive("error", () => {
                window.userToken = ""
                console.log("Error channel")
            })

            userChannel.on("joined", payload => {
                dispatch({
                    type: Constants.CURRENT_USER,
                    currentUser: payload.data,
                    socket: socket,
                    channel: userChannel,
                })

                dispatch(getDashboard(payload.data.id, socket))
                getAuthTokens(userChannel)
            })

            userChannel.on("logged_out", () => {
                // close modals (saving data)
                let timeoutEvent = new CustomEvent("timeout", {})

                document.body.dispatchEvent(timeoutEvent)

                window.userToken = ""
                dispatch({
                    type: Constants.USER_SIGNED_OUT
                })
                socket.disconnect()

                fetch("/auth/signout", {
                    method: "POST",
                    headers: {
                        "x-csrf-token": window.csrfToken,
                    },
                    credentials: "same-origin"
                })
            })

            userChannel.on("created_token", payload => {
                dispatch({
                    type: Constants.CREATE_TOKEN,
                    payload: payload
                })
            })

            userChannel.on("deleted_token", payload => {
                dispatch({
                    type: Constants.DELETE_TOKEN,
                    payload: payload
                })
            })

            userChannel.on("token_list", payload => {
                payload.data.map( token => {
                    dispatch({
                        type: Constants.CREATE_TOKEN,
                        payload: token
                    })
                })
            })
        })

        socket.onError((error) => {
            // Is triggered when there is no response from server.
            // close modals (saving data)
            let timeoutEvent = new CustomEvent("timeout", {})

            document.body.dispatchEvent(timeoutEvent)

            // Clear state of browser app
            dispatch({
                type: Constants.USER_SIGNED_OUT
            })
            window.userToken = ""

            // Push Logout Event and Terminate Channel connection
            userChannel.push("logout")
            socket.disconnect()

            alert("This session has disconnected. To resume work, please refresh your browser and log back in.")
        })
    }
}

export function signOut(channel) {
    return (dispatch) => {
        channel.push("logout")
    }
}

export const getAuthTokens = (channel) => {
    channel.push("get_tokens")
}

export const createAuthToken = (channel, label) => {
    channel.push("create_token", {label: label})
}

export const deleteAuthToken = (channel, token) => {
    channel.push("delete_token", {token: token})
}
