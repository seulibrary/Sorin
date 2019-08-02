import React, { Component } from "react"

export default class FourOFour extends Component {
    render() {
        let style = {
            padding: "1em",
            margin: "0 auto",
            textAlign: "center"
        }
        return (
            <div style={style}>
                <h1>404</h1>
                Page Not Found.
            </div>
        )
    }
}