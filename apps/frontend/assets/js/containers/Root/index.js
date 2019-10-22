import React, { Component } from "react"
import Hamburger from "../../components/Hamburger"
import ModalContainer from "../../components/Modal/Container"
import { openModal } from "../../actions/modal"
import { uuidv4 } from "../../utils"
import { withRouter, NavLink } from "react-router-dom"
import { connect } from "react-redux"
import Notice from "../../components/Notice"
import Header from "../../components/Header"
class Root extends Component {
    constructor(props) {
        super(props)
        this.state = {
            showNotice: false
        }
    }

    activeEvent = (match, location) => {
        if (location.pathname === "/" || match) {
            return true
        }

        return false
    }

    loginBlocked = (e) => {
        e.preventDefault()

        this.props.dispatch(
            openModal({
                id: uuidv4,
                type: "confirmation",
                buttonText: ["Sign in", "Cancel"],
                onConfirm: () => {
                    window.location.href = "/auth/google"
                },
                onCancel: () => {},
                text: "Please sign in to access collections."
            })
        )

        return false
    }

    notificationCount = () => {
        if (this.props.notifications.saveNotificationCount == 0) {
            return 
        }
        
        let notificationStyle = {
            backgroundColor: "#f1714b",
            borderRadius: ".8em",
            color: "#ffffff",
            display: "inline-block",
            lineHeight: "1.6em",
            textAlign: "center",
            width: "1.6em"
        }

        return (
            <span style={notificationStyle}>{this.props.notifications.saveNotificationCount}</span>
        )
    }

    render() {
        return (
            <main role="main" id="main">
                <header id="header">
                    <Header />

                    <Hamburger />
                </header>

                    <ul className="tabs" id="tabs">
                        <li className="tab">
                            <NavLink to="/search" activeClassName="active" isActive={this.activeEvent}>Search</NavLink>
                        </li>
                        <li className="tab">
                            {this.props.session.currentUser ?
                                <NavLink to="/collections" activeClassName="active">Collections {this.notificationCount()}</NavLink>
                                :
                                <NavLink to="/collections" onClick={this.loginBlocked} activeClassName="active">Collections</NavLink>
                            }
                        </li>
                    </ul>
                
                <Notice />

                <div className="panels">
                    {this.props.children}
                </div>

                <ModalContainer />
            </main>
        )
    }
}

export default withRouter(connect(
    function mapStateToProps(state) {
        return {
            modals: state.modals,
            session: state.session,
            notifications: state.notifications
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Root))
