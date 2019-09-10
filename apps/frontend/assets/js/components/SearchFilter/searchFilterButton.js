import React, { Component } from "react"
import { connect } from "react-redux"
import { addComponentsToArea } from "../../actions/extensions"
import ErrorBoundary from "../../containers/Errors"

class SearchFilterButton extends Component {
    componentDidUpdate(prevProps) {
        if (prevProps.extensions.files.length != this.props.extensions.files.length) {
            this.props.extensions.files.map(el => {
                if (el.path === "searchFilterButton") {
                    this.props.dispatch(addComponentsToArea({searchFilterButton: [el]}))
                }
            })
        }
    }

    componentDidMount(e) {
        if (!this.props.extensions.hasOwnProperty("searchFilterButton")) {
            this.props.extensions.files.map(el => {
                if (el.path === "searchFilterButton") { 
                    this.props.dispatch(addComponentsToArea({searchFilterButton: [el]}))
                }
            })
        }
    }
    
    renderExtensions = () => {
        if (this.props.extensions.hasOwnProperty("searchFilterButton")) {
            return this.props.extensions.searchFilterButton.map( (extension, i) => {
                if (extension.component) {   
                    var Component = extension.component

                    return <Component key={"search-filter-extension-Button" + i} index={i} />
                }
            })
        }
        return null
    }

    render() {
        return (
            <React.Fragment>
                <ErrorBoundary>    
                    {this.renderExtensions()}
                </ErrorBoundary>
            </React.Fragment>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            extensions: state.extensions
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(SearchFilterButton)
