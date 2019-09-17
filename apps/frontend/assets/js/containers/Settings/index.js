import React, { Component } from "react"
import { withRouter } from "react-router-dom"
import { connect } from "react-redux"
import Accordion from "../../components/Accordion"
import { getAuthTokens, deleteAuthToken, createAuthToken } from "../../actions/sessions.js"
import Clipboard from "../../components/Clipboard"
import { openModal } from "../../actions/modal"
import { uuidv4 } from "../../utils"

class Settings extends Component {
    constructor(props) {
        super(props)
        this.state = {
            copied: false,
            label: ""
        }
    }

    createToken = (e) => {
        if (this.state.label) {
            createAuthToken(this.props.session.channel, this.state.label)
            this.setState({label: ""}) } else {
                this.props.dispatch(
                    openModal({
                        id: uuidv4,
                        type: "alert",
                        text: <div>{"You need a label for this token."}</div>
                    }))
            }

    }

    handleChange = (e) => {
        this.setState({
            label: e.target.value
        })
    }

    deleteToken = (channel, token) => {
        deleteAuthToken(channel, token)
    }

    confirmDelete = (e) => {
        e.preventDefault()

        let token = e.currentTarget.dataset.token

        this.props.dispatch(
            openModal({
                id: uuidv4,
                type: "confirmation",
                onCancel: () => {},
                onConfirm: () => {
                    this.deleteToken(this.props.session.channel, token)
                },
                text: <div>{"Are your sure you want to delete this auth token?"}</div>
            })
        )
    }

    copyToken = () => {
        return null
    }

    render() {
        return (
            <div id="about">
                <div className="settings-section">
                    <h1>User Settings</h1>
                    <h3>Name</h3>
                    <p>{this.props.session.currentUser.fullname}</p>
                    <h3>Email</h3>
                    <p>{this.props.session.currentUser.email}</p>

                    <Accordion title="API Tokens" symbolPosition="left">
                        <h4>Api Tokens</h4>
                        {this.props.session.auth_tokens.map((token, index) => {
                             return (
                                 <div key={"auth_token_" + index}>
                                     <span>{token.label}</span>
                                     <Clipboard idName="auth-tokens" onCopy={this.copyToken} copied={this.state.copied} value={token.token} />
                                     <span onClick={this.confirmDelete} data-token={token.token}>Delete</span>
                                 </div>
                             )
                        })}
                        <div>
                            Label
                            <input onChange={this.handleChange} value={this.state.label} type="text" />
                            <span onClick={this.createToken}>Create Token</span>
                        </div>

                    </Accordion>
                </div>
            </div>
        )
    }
}

export default withRouter(connect(
    function mapStateToProps(state) {
        return {
            session: state.session
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Settings))
