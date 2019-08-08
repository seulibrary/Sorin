import React, { Component } from "react"

class Login extends Component {
    render() {
        return (
            <div id="welcome">
                <h1>Welcome to Sorin</h1>
                <h4>Search, Organize, Research, INteract</h4>

                <a id="sign-gmail" href="/auth/google">
                    <span>Sign in with your Gmail account</span>{" "}
                    <img src="images/gmail.png" />
                </a>
            </div>
        )
    }
}

export default Login
