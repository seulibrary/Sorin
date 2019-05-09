import React, { Component } from "react"
import { connect } from "react-redux"
import { signOut } from "../../actions/sessions"

class Hamburger extends Component {
    constructor(props) {
        super(props)
        this.state = {
            isVisible: false
        }

        this.toggleVisible = this.toggleVisible.bind(this)
        this.handleKeyPress = this.handleKeyPress.bind(this)
    }
    
    componentDidMount() {
        document.body.addEventListener("keydown", this.handleKeyPress)
    }

    componentWillUnMount() {
        document.body.removeEventListener("keydown", this.handleKeyPress)
    }

    handleKeyPress(e) {
        if (e.keyCode == 27 && this.state.isVisible == true) {
            this.setState({isVisible: false})
        }
    }

    toggleVisible(e) {
        if (e.target === e.currentTarget || e.target.classList.contains("hamburger")) {
            this.setState({isVisible: !this.state.isVisible})
        }
    }
    
    render() {
        return (
            <div className="navigation">
                <div className={ this.state.isVisible? "open-hamburger hamburger-wrapper" : "hamburger-wrapper"} onClick={this.toggleVisible}>
                    <div className="hamburger top-bar"></div>
                    <div className="hamburger mid-bar"></div>
                    <div className="hamburger mid-bar2"></div>
                    <div className="hamburger bottom-bar"></div>
                </div>

                {this.state.isVisible && <Menu {...this.props} onKeyPress={this.handleEscapeKeyPress} onClick={this.toggleVisible} />}
            </div>
        )
    }
}

class Menu extends Hamburger {
    constructor(props) {
        super(props)
    }

    signOutUser = () => {
        signOut(this.props.session.channel)
    }

    render() {
        return (
            <div className="navigation-wrapper" onClick={this.props.onClick} onKeyPress={this.props.onKeyPress}>
                <div className="navigation-menu">
                    <h4>{this.props.settings.app_name}</h4>
                    <ul>
                        {this.props.session.currentUser ? 
                            <li>
                        Welcome, {this.props.session.currentUser.fullname}<br />
                                <a href="/auth/signout" onClick={this.signOutUser}>Sign Out</a>
                            </li> :
                            <li>
                                <a href="/auth/google">Sign In</a>
                            </li>
                        }
                        <li><a href="/about">About {this.props.settings.app_name}</a></li>
                    
                    </ul>
                </div> 
            </div>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            settings: state.settings,
            session: state.session,
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch,
        }
    }
)(Hamburger)