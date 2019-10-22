import React, { Component } from "react"
import { connect } from "react-redux"
import Accordion from "../Accordion"
import RichTextEditor from "../RichTextEditor"
import Tags from "../Tags"
import { cloneCollection, importCollection } from "../../actions/collections"
import InnerResource from "../CollectionResource/InnerResource"
import { downloadFile } from "../../actions/files"
import { addSaveNotification } from "../../actions/notifications"

class CollectionResult extends Component {
    constructor(props) {
        super(props)

        this.state = {
            clone: "clone",
            import: "import"
        }
    }

handleClone = (e) => {
    e.preventDefault()

    if (this.state.clone != "cloned!") {
        this.setState({
            clone: "cloned!"
        })

        cloneCollection(this.props.session.dashboardChannel, this.props.data.id)
        this.props.dispatch(addSaveNotification())
    }
}

handleImport = (e) => {
    e.preventDefault()

    if (this.state.import != "imported!") {
        this.setState({
            import: "imported!"
        })

        importCollection(this.props.session.dashboardChannel, this.props.data.id)
        this.props.dispatch(addSaveNotification())
    }
}

downloadFile = e => {
    e.preventDefault()

    downloadFile(e.currentTarget.dataset.id)
}

render() {
    const data = this.props.data

    return (
        <div className="result show">
            <span className="count">{this.props.index + 1}</span>
            <div className="info coll">
                <h4>
                    {data.title}
                </h4>
                <p>Creator(s): {data.write_users.map( (author, index) => {
                    return (
                        <React.Fragment key={"author-" + author + index}>
                            {author}{data.write_users.length != index + 1 && index + 1 < data.write_users.length ? ", " : ""}
                        </React.Fragment>
                    )
                })} </p>
                <p>Clone Count: {data.clones_count}</p>
                {this.props.data.files.length > 0 ? <span className="attach"></span> : "" }
            </div>

            <div className="actions">
                <a className="save" onClick={this.handleClone}>
                    <span className="flag">{this.state.clone}</span>
                </a>

                <a className="save import" onClick={this.handleImport}>
                    <span className="flag">{this.state.import}</span>
                </a>
            </div>
            
            <Accordion title={"Resources"} titleClass={"more-info"}>
                <div className="resource-group">
                    {data.resources.map((resource, index) => {
                        return (
                            <div
                                key={"collection-result-div" + resource.id}
                            >
                                <InnerResource
                                    key={"inner-resource-result-" + resource.id}
                                    index={index}
                                    title={resource.title}
                                    data={resource}
                                    id={resource.id}
                                    type={resource.type}
                                    canEdit={false}
                                    channel={this.props.channel}
                                    hasFiles={(resource.files.length > 0)}
                                    parent={this.props.parent} />

                                {resource.files.length > 0 ? <span className="attach"></span> : "" }
                            </div>
                        )
                    })}
                </div>
            </Accordion>

            {this.props.data.files.length > 0 ? (
                <Accordion title="Attachment" titleClass={"more-info"}>   
                    <div className={"resource-group"}>
                        {this.props.data.files.map((f) => (
                            <a key={f.uuid}>
                                <b
                                    className="filename"
                                    title={f.size + " Bytes - Click to download attachment"}
                                    onClick={this.downloadFile}
                                    data-id={f.uuid}

                                >
                                    {f.title}
                                </b>
                            </a>
                        ))}
                    </div>
                </Accordion>
            ) : ""}

            <Accordion title={"Notes"} titleClass={"more-info"}>
                <RichTextEditor 
                    key={data.notes != null ? data.notes.id : ""}
                    id={data.notes != null ? data.notes.id : ""}
                    onChange={() => { return false }}
                    data={data.notes != null ? data.notes.body : ""}
                    writeAccess={false}
                />
            </Accordion>

            <Accordion title={"Tags"} titleClass={"more-info"}>
                <Tags data={data.tags || []} onChange={() => { return false }} disabled={true} />
            </Accordion>
        </div>
    )
}
}

export default connect(
    function mapStateToProps(state) {
        return {
            session: state.session,
            settings: state.settings
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch,
        }
    }
)(CollectionResult)