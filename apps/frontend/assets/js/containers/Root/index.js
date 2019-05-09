import React, { Component } from "react"
import Hamburger from "../../components/Hamburger"
import ModalContainer from "../../components/Modal/Container"
import { withRouter, NavLink } from "react-router-dom"
import { connect } from "react-redux"
import Notice from "../../components/Notice"
import Header from "../../components/Header"
class Root extends Component {
    constructor(props) {
        super(props)  
    }

    activeEvent = (match, location) => {
        if (location.pathname === "/" || match) {
            return true
        }

        return false
    }

    render() {
        return (
            <main role="main" id="main">
                <header id="header">
                    <Header />

                    <Hamburger />
                </header>

                {this.props.session.currentUser && 
                    <ul className="tabs" id="tabs">
                        <li className="tab">
                            <NavLink to="/search" activeClassName="active" isActive={this.activeEvent}>Search</NavLink>
                        </li>
                        <li className="tab">
                            <NavLink to="/collections" activeClassName="active">Collections</NavLink>
                        </li>
                    </ul>
                }
                
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
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Root))
