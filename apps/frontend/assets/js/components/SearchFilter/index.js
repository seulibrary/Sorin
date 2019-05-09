import React, { Component } from "react"
import { connect } from "react-redux"
import { addComponentsToArea } from "../../actions/extensions"
import ErrorBoundary from "../../containers/Errors"

class SearchFilter extends Component {
    componentDidUpdate(prevProps) {
        if (prevProps.extensions.files.length != this.props.extensions.files.length) {
            this.props.extensions.files.map(el => {
                if (el.path === "searchFilter") {
                    this.props.dispatch(addComponentsToArea({searchFilter: [el]}))
                }
            })
        }
    }

    componentDidMount() {
        this.props.extensions.files.map(el => {
            if (el.path === "searchFilter") {
                this.props.dispatch(addComponentsToArea({searchFilter: [el]}))
            }
        })
    }
    
    renderExtensions = () => {
        if (this.props.extensions.searchFilter) {
            return this.props.extensions.searchFilter.map( (extension, i) => {
                if (extension.component) {   
                    var Component = extension.component

                    return <Component key={"search-filter-extension-" + i} index={i} searchFilters={this.props.searchFilters} search={this.props.search} onSumbit={this.props.onSumbit} />
                }
            })
        }
        return null
    }

    render() {
        const showFilters = this.props.extensions.searchFilter

        return (
            <React.Fragment>
                { showFilters ? 
                    <React.Fragment>
                        
                        <ErrorBoundary>    
                            {this.renderExtensions()}
                        </ErrorBoundary>
    
                    </React.Fragment>
                    : null
                }
            </React.Fragment>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            search: state.search,
            searchFilters: state.searchFilters,
            extensions: state.extensions
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(SearchFilter)
