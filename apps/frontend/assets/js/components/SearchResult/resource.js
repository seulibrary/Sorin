import React, { Component } from "react"
import { connect } from "react-redux"
import Citation from "../Citation"


class ViewResource extends Component {
    
        constructor(props) {
            super(props)

            this.state = {
                data: {},
                currentIndex: 0,
                hasCatalogResults: false
            }
        }

        componentDidMount() {
            this.setState({
                data: this.props.data,
                currentIndex: this.props.index,
                hasCatalogResults: this.props.search.searchResults.catalogs.num_results > 0,
                resultLength: this.props.search.searchResults.catalogs.results.length
            })
        }

        nextResource = () => {
            if (this.state.hasCatalogResults && this.props.index + 1 < this.state.resultLength) {
                let nextResource = this.props.search.searchResults.catalogs.results[this.state.currentIndex + 1]
                
                this.setState({
                    data: nextResource,
                    currentIndex: this.state.currentIndex + 1
                })
            }

            return 
        }

        previousResource = () => {
            if (this.state.hasCatalogResults && (this.state.currentIndex + 1) > 1) {
                let prevResource = this.props.search.searchResults.catalogs.results[this.state.currentIndex - 1]
                
                this.setState({
                    data: prevResource,
                    currentIndex: this.state.currentIndex - 1
                })
            }

            return
        }

        render() {
            let data = this.state.data || this.props.data
        return (
        <div>
                <div className="container">
                    <div className="resource-column-left">
                        <span onClick={this.previousResource}>Prev</span>
                        <span onClick={this.nextResource}>Next</span>

                        <div
                            className={"resource-box-icon icon " + data.type}
                        />
{/*                         
                        {data.catalog_url && (
                            <a
                                title="Go To Link"
                                className="resource-box-link"
                                target="_blank"
                                href={ 
                                    !data.catalog_url.match(/^[a-zA-Z]+:\/\//) ?
                                        "//" + data.catalog_url : data.catalog_url }
                            >
                                OPEN
                            </a>
                        )} */}
                    </div>

                    <div className="resource-column-middle">
                        <label>
                            
                            
                            {data.type}
{/*                             
                            {data.catalog_url && (
                                <a
                                    title="Go To Link"
                                    className="mobile-only resource-box-link"
                                    target="_blank"
                                    href={ 
                                        !data.catalog_url.match(/^[a-zA-Z]+:\/\//) ?
                                            "//" + data.catalog_url : data.catalog_url }
                                >
                                OPEN
                                </a>
                            )} */}
                        </label>
                      
                        <span className={"full-width resource-title"}>
                            {data.title}
                        </span>
                      
                      
                        {data.description && (
                      
                    <div>{data.description}</div>
                      
                        )}

                        {data.identifier && (
                            
                                <input
                                    type="text"
                                    className="full-width"
                                    readOnly={true}
                                    name="url"
                                    placeholder="Item URL"
                                    value={data.catalog_url}
                                />
                            
                        )}


                        <Citation data={data} />

                    </div>

                    <div className="resource-column-right">
                        
                    </div>
                </div>

                <div className="controls">
                  
                </div>
            </div>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            session: state.session,
            collections: state.collections,
            settings: state.settings,
            search: state.search
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(ViewResource)
