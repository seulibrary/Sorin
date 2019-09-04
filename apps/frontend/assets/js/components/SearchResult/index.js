import React, { Component } from "react"
import Citation from "../Citation"
import { connect } from "react-redux"
import { openModal } from "../../actions/modal"
import { uuidv4 } from "../../utils"
import Accordion from "../Accordion"
import { createResource, saveResourceToCookie } from "../../actions/collections"
import { Redirect } from 'react-router'
import {withRouter} from 'react-router-dom'

class SearchResult extends Component {
    constructor(props) {
        super(props)

        this.state = {
            saveit: "save it!"
        }
    }

    onSave = () => {
        if (this.state.saveit != "saved!") {
            if (!this.props.session.currentUser) {
                this.setState({
                    saveit: "saving..."
                })
                // save item to local storage
                this.props.dispatch(
                    openModal({
                        id: uuidv4,
                        type: "confirmation",
                        buttonText: ["Sign in", "Cancel"],
                        onConfirm: () => {
                            let params = this.props.location.search ? this.props.location.search : "";
                            let login_state = JSON.stringify({url: this.props.location.pathname + params});

                            saveResourceToCookie(this.props.data, login_state)
                        },
                        onCancel: () => {
                            this.resetSaveItState()
                        },
                        onClose: () => {
                            this.resetSaveItState()
                        },
                        text: "Would you like to sign in and save this item?"
                    })
                )
            } else {
                this.setState({
                    saveit: "saved!"
                })
                
                let inbox = this.props.collections.collections.map( collection => {
                    if (collection.data.collection.id === this.props.session.inbox_id) {
                        return collection
                    }
                })
    
                if (inbox.length > 0) {
                    createResource(inbox[0].channel, this.props.session.inbox_id, this.props.data)
                } else {
                    this.setState({
                        saveit: "Not Saved!"
                    })
                }
            }    
        }
    }

    resetSaveItState = () => {
        this.setState({
            saveit: "save it!"
        })
    }

    checkInbox = (resource) => {
        if (this.props.collections.collections.length > 0) {
            let resources = this.props.collections.collections[0].data.collection.resources // inbox resources
            if (resources.length > 0) {
                resources.map( res => {
                    if (res.identifier === resource.identifier) {
                        this.setState({
                            saveit: "saved!"
                        })
                    }
                })
            }
        }
    }

    componentDidMount() {
        this.checkInbox(this.props.data)
    }

    render() {
        const data = this.props.data
        
        return (
            <div className="result show">
                <span className="count">{this.props.index + 1}</span>
                <div className={"icon " + data.type}></div>
                <div className="info">
                    <h5><span>{data.type}</span></h5>
                    <h4>
                        <a target="_blank" href={data.catalog_url}>{data.title}</a>
                        { data.date ? <i>({data.date})</i> : "" }
                    </h4>
                    <div className="contrib">
                      
                        <span><i>{data.creator ? data.creator.join("; "): ""}</i></span>
                        
                        <span>
                        {data.contributor ? data.contributor.join("; "): ""}
                        </span>

                        <span>{data.is_part_of}</span>
                        
                        { data.call_number && data.availability_status == "available" && <span className="callNumber">Available in the book stacks {data.call_number}</span> }
                        
                        { data.call_number && data.availability_status == "unavailable" && <span className="callNumber">Unavailable {data.call_number}</span> }

                        {data.description ? <Accordion title="More Info" titleClass={"more-info"}>
                            <div>
                                <h5>Description</h5> 
                                {data.description}
                            </div>
                        </Accordion> : "" }
                    </div>

                    <span className="avail"></span>
                    <div className="des">
                        <span>link</span>
                        <span>notes</span>
                    </div>
                </div>

                <div className="actions">
                    <a className="save" data-context="L" onClick={this.onSave}>
                        <span className="flag">{this.state.saveit}</span>
                    </a>
                    <a className="save url" target="_blank" href={data.catalog_url} >
                        <span className="flag">View resource</span>
                    </a>

                    <button className="cite save" onClick={() => this.props.dispatch(openModal({
                        id: uuidv4(),
                        type: "custom",
                        panel: "search",
                        content: <Citation data={data} />
                    }))}><span className="flag action-modal">cite</span></button> 
                </div>
            </div>
        )
    }
}

export default withRouter(connect(
    function mapStateToProps(state) {
        return {
            modals: state.modals,
            session: state.session,
            collections: state.collections
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(SearchResult))
