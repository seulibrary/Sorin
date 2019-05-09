import Constants     from "../constants"  
import { Socket } from "../../../../../deps/phoenix"
import { getDashboard } from "../actions/collections"
import { joinSearchChannel } from "../actions/search"

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

                dispatch(joinSearchChannel())
                dispatch(getDashboard(payload.data.id, socket))
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
                    }
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