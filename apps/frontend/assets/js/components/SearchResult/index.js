import React, { Component } from "react"
import Citation from "../Citation"
import { connect } from "react-redux"
import { openModal } from "../../actions/modal"
import { uuidv4 } from "../../utils"
import Accordion from "../Accordion"
import { createResource } from "../../actions/collections"

class SearchResult extends Component {
    constructor(props) {
        super(props)

        this.state = {
            saveit: "save it!"
        }
    }

    onSave = () => {
        if (this.state.saveit != "saved!") {
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
                        <span><i>{data.creator}</i></span>
                        <span>{data.contributor}</span>
                        <span>{data.is_part_of}</span>
                        { data.call_number && <span className="callNumber">Available at Munday Library Book Stacks {data.call_number}</span> }

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

export default connect(
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
)(SearchResult)
