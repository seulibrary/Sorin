import React, { Component } from "react"
import { connect } from "react-redux"
import { addComponentsToArea } from "../../actions/extensions"
import ErrorBoundary from "../../containers/Errors"
import "./header.scss"
class Header extends Component {
    componentDidUpdate(prevProps) {
        if (prevProps.extensions.files.length != this.props.extensions.files.length) {
            this.props.extensions.files.map(el => {
                if (el.path === "header") {
                    this.props.dispatch(addComponentsToArea({header: [el]}))
                }
            })
        }
    }

    componentDidMount() {
        this.props.extensions.files.map(el => {
            if (el.path === "header") {
                this.props.dispatch(addComponentsToArea({header: [el]}))
            }
        })
    }
    
    renderExtensions = () => {
        if (this.props.extensions.header) {
            return this.props.extensions.header.map( (extension, i) => {
                if (extension.component) {   
                    var Component = extension.component

                    return <Component index={i} key={"header-" + i} />
                }
            })
        }
       
        return null
    }

    fallback = () => {
        const headerStyle = {
            color: "white",
            fontSize: "400%",
            display: "flex",
            justifyContent: "center",
            flexDirection: "column",
            textAlign: "center",
            margin: "0 0 0 .25em",
            padding: 0
        }
        
        if (this.props.extensions.extensionsLoaded) {
            return <React.Fragment>
                <a href="/" className="logoTree">
                    <img src="/images/logoTree.svg" alt="Sorin by St. Edward's University Munday Library" />
                </a>

                <div className="logoText">
                    <a href="/" className="logoSorin">
                        <img src="/images/logoNewSorin.svg" alt="Sorin by St. Edward's University Munday Library" />
                    </a>
                    <a href="https://library.stedwards.edu/" className="logoBy" target="_blank">
                        <img src="/images/logoByML.svg" alt="Sorin by St. Edward's University Munday Library" />
                    </a>
                    <a href="https://library.stedwards.edu/" className="logoBy-sm" target="_blank">
                        <img src="/images/logoByML-sm.svg" alt="Sorin by St. Edward's University Munday Library" />
                    </a>
                </div>
            </React.Fragment>
        } 

        return ""
    }

    render() {
        const showFilters = this.props.extensions.header

        return (
            <React.Fragment>
                { showFilters ? 
                    <React.Fragment>
                        
                        <ErrorBoundary>    
                            {this.renderExtensions()}
                        </ErrorBoundary>
    
                    </React.Fragment>
                    : this.fallback()
                }
            </React.Fragment>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            extensions: state.extensions,
            settings: state.settings
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Header)