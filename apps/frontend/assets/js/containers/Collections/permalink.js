import React, { Component } from "react"
import { connect } from "react-redux"
import { getCollection } from "../../actions/collection"
import PermaLinkResource from "../../components/CollectionResource/PermaLinkResource"
import RichTextEditor from "../../components/RichTextEditor"
import Loader from "../../components/Loader"
import { withRouter } from "react-router-dom"

class PermalinkCollectionView extends Component {
    componentDidMount = () => {
        if (!this.props.collection.collectionLoading) {
            this.props.dispatch(
                getCollection(
                    this.props.settings.api_port,
                    this.props.match.params.collection_url
                )
            )
        }
    }

    renderCollection = () => {
        let data = this.props.collection.collection

        if (data.hasOwnProperty("title")) {
            return <div className="info">
                <h3>
                    {data.title}
                </h3>
                
                <p>Published: <b>{data.published ? "Yes" : "No"}</b> | Clone Count: <b>{data.clones_count}</b> | Provenance: <b>{ data.provenance ? data.provenance : "None" }</b></p>

                <RichTextEditor 
                    onChange={() => { return false }}
                    data={data.notes != null ? data.notes.body : ""}
                    writeAccess={false}
                />
                    
                <h4>Resources:</h4>
                    
                <div className="resource-group">
                    { typeof(this.props.collection.collection.resources) == "object" ? data.resources.map((resource, index) => {
                        return (
                            <PermaLinkResource
                                key={resource.id}
                                data={resource}
                                index={index}
                                panel={"permalink"}
                                parent={data.id} />
                        )
                    }) : "" }
                </div>
            </div>
        }

        if (data.hasOwnProperty("errors")) {
            return <div className="info">
                <h3>No Collection Found.</h3>
            </div>
        }
        
        return null
    }

    render() {
        return (
            <div className="result show" id="perma-link">
                <Loader isVisible={this.props.collection.collectionLoading}>
                    <div>{this.renderCollection()}</div>
                </Loader>
            </div>
        ) 
    }
}

export default withRouter(connect(
    function mapStateToProps(state) {
        return {
            settings: state.settings,
            collection: state.collection,
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(PermalinkCollectionView))
