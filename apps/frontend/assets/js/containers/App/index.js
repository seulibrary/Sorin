import React, { Component } from "react"
import { connect } from "react-redux"
import { bindActionCreators } from "redux"
import { 
    Route, 
    withRouter, 
    Switch, 
    Redirect 
} from "react-router-dom"
import { setCurrentUser } from "../../actions/sessions"
import IdleTimer from "react-idle-timer"
import Root from "../Root"
import withTracker from "../../store/tracker"
import PermalinkCollectionView from "../Collections/permalink"
import About from "../About"
// import Settings from "../Settings"
// import Login from "../Login"
import Search from "../Search"
import Collections from "../Collections"
import {addExtensions, extensionsLoaded} from "../../actions/extensions"
import { getSiteSettings, uuidv4 } from "../../utils"
import FourOFour from "../Errors/404.js"

class App extends Component {
    constructor(props) {
        super(props)
    }
    
    componentWillMount() {
        this.checkAuth()
        this.props.dispatch(getSiteSettings())
    }

    componentDidMount() {
        let extensions = EXTERNAL_EXTENSIONS.map(plugin => {
            let path = plugin.split("/")

            let waitForChunk = import(`../../extensions/${path[path.length -1]}/settings.js`)
        
            return new Promise((resolve, reject) => waitForChunk.then( resp => {
                resolve(resp.components)
            }))
        })
            
        Promise.all(extensions)
            .then(res => {
                const exts = res.reduce((prev, current) => prev.concat(current), [])

                this.props.dispatch(addExtensions(exts))
                
                if (EXTERNAL_EXTENSIONS.length >= exts.length) {
                    this.props.dispatch(extensionsLoaded())
                }
            })
    }

    checkAuth = () => {
        if (window.userToken) {
            this.props.dispatch(setCurrentUser())
        }
    }

    exitApp = () => {
        let timeoutEvent = new CustomEvent("timeout", {})

        document.body.dispatchEvent(timeoutEvent)

        this.props.session.channel.push("logout")
    }

    render() {
        return(
            <Root>
                <Switch>
                    <Route exact path="/" extensions={this.props.extensions} component={withTracker(Search)} exitApp={this.exitApp} />

                    <Route path="/c/:collection_url" component={withTracker(PermalinkCollectionView)} />
                    <Redirect from="/c" to="/c/404" />
                    
                    <Route path="/about" component={withTracker(About)} />
                    <Route path="/search" extensions={this.props.extensions} component={withTracker(Search)} exitApp={this.exitApp} />
                    
                    {/* <ProtectedRoute path="/settings" permission={this.props.session.currentUser} extensions={this.props.extensions} component={withTracker(Settings)} exitApp={this.exitApp} /> */}
                    <ProtectedRoute path="/collections" permission={this.props.session.currentUser} component={withTracker(Collections)} exitApp={this.exitApp} />
                    
                    <Route component={withTracker(FourOFour)} exitApp={this.exitApp} />
                </Switch>
            </Root>
        )
    }
}

class ProtectedRoute extends Component {
    onIdle = (e) => {
        this.props.exitApp()
    }

    render() {
        const { component: Component, ...props } = this.props

        return (
            <Route
                {...props}
                render={props => (
                    this.props.permission ?
                        <React.Fragment>
                            <IdleTimer
                                ref={ref => { this.idleTimer = ref }}
                                element={document}
                                onIdle={this.onIdle}
                                debounce={250}
                                timeout={1000 * 60 * 60 * 8} />

                            <Component {...props} />
                        </React.Fragment> :
                        <Search loginPrompt={true} />
                )}
            />
        )
    }
}

export default withRouter(connect(
    function mapStateToProps(state) {
        return {
            session: state.session,
            extensions: state.extensions
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch,
        }
    }
)(App))
