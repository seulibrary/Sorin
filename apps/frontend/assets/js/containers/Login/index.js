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

                <p>
                Sorin is a new research tool for searching library content,
                saving results into collections, generating citations, and
                much more. After you log in, do a search in the Library
                Search bar, click “Save it!” to keep your favorite results,
                and organize your research into groups in the “Collections”
                tab.
                </p>
            </div>
        )
    }
}

export default Login
