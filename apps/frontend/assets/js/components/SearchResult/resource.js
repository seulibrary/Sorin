import React, { Component } from "react"
import { connect } from "react-redux"
import Accordion from "../Accordion"
import Citation from "../Citation"
import { createResource, saveResourceToCookie } from "../../actions/collections"


class ViewResource extends Component {
    
        constructor(props) {
            super(props)

            this.state = {
                data: {},
                currentIndex: 0,
                hasCatalogResults: false
            }
            
            this.state = {
	            saveit: "save to Inbox",
	            clicked: ""
	        }
        }
        
        onSave = () => {
	        if (this.state.saveit != "saved!") {
	            if (!this.props.session.currentUser) {
	                this.setState({
	                    saveit: "saving...",
	                    clicked: " clicked"
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
	                    saveit: "saved!",
	                    clicked: " clicked"
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
	                        saveit: "Not Saved!",
	                        clicked: " error"
	                    })
	                }
	            }    
	        }
	    }

	    resetSaveItState = () => {
	        this.setState({
	            saveit: <span>save to collections</span>
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
            console.log(data);
            let subjects = data.subject ? data.subject[0].split(" ; ") : []
            

        return (
        <div  className="resource-form">
                <div className="container">
                    <div className="resource-column-left">
                        <span onClick={this.previousResource} className="arrow arrow-up">Prev</span>
                        

                        <div
                            className={"resource-box-icon icon " + data.type}
                        />
{ /*                         
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

                        <span onClick={this.nextResource} className="arrow arrow-down">Next</span>
                    </div>

                    

                    <div className="resource-column-middle">
                        <label>
                            
                            
                            {data.type} 


                            {data.call_number && (

                            <span class="callNumber available green">  - Munday Library Stacks {data.call_number} - {data.availability_status}</span>

                            )}
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
                      
                        <h2 className={"full-width resource-title"}>
                            {data.title} <span><i>({data.date})</i></span>
                        </h2>
                        {data.is_part_of && (
                      
                      <p><i>
                  
                      
                      {data.is_part_of}
                      
                      </i></p>

                  
                    )}
                        
                        {data.creator && (
                      
	                    <div>
	                    <h4 className="more-info">Author(s):</h4>
	                    

                        
                        <ul className={"subjects"}>
                            
                            {data.creator.map((c, index) => (
                                <li key={index}>
                                    

                                    <a 
                                    href= {"/search?query=" + c  }

                                    ///search?query=Martin%2C+Kirsten&filters=%5Bsearch_by=creator%26item_type=all%26sort_by=rank%5D
                                    >
                                        
                                        {c}
                                    </a>
                                    
                                </li>
                            ))}
                        </ul>
	                    
	                    
	                    </div>
                      
                        )}

                       
                        {data.description && (
                      
	                    <div>
	                        <h4 className="more-info">Description:</h4>
	                        {data.description}
	                    </div>
                      
                        )}

                        {data.publisher && (
                                    
                        <div>
                            <h4 className="more-info">Publication:</h4>
                            {data.publisher}
                        </div>
                    
                        )}

                        
                        {data.subject && (
                      
	                    <div>
	                        <h4 className="more-info">Subject:</h4>
	                    
                        
                        

                        <ul className={"subjects"}>
                            
                            {subjects.map((f, index) => (
                                <li key={index}>
                                    <a 
                                    href= {"/search?query=" + f + "&filters=[search_by=sub]"}

                                    ///search?query=Martin%2C+Kirsten&filters=%5Bsearch_by=creator%26item_type=all%26sort_by=rank%5D
                                    >
                                        
                                        {f}
                                    </a>
                                    
                                </li>
                            ))}
                        </ul>
	                    
	                    
	                    </div>
                      
                        )}


                            {data.format && (
                                    
                                    <div>
                                        <p><b >FORMAT: </b>
                                        
                                        {data.format}
                                        
                                        </p>
                                    </div>
                                
                                    )}

                                    {data.language && (
                                    
                                    <div>
                                        <p><b >LANGUAGE: </b>
                                        
                                        {data.language}
                                        
                                        </p>
                                    </div>
                                
                                    )}

                                        {data.doi && (
                                    
                                    <div>
                                    <p><b >DOI: </b>
                                    
                                    {data.doi}
                                    
                                    </p>
                                    </div>
                                
                                    )}


                        {data.identifier && (
                             <Accordion
                             title={"Item URL"}
                             titleClass={"more-info"}
                         >
                                <input
                                    type="text"
                                    className="full-width"
                                    readOnly={true}
                                    name="url"
                                    placeholder="Item URL"
                                    value={data.catalog_url}
                                />

                            </Accordion>
                            
                        )}

                        
						
                        
                        
                        <Accordion title={"Citations"} titleClass={"more-info"}>
                            <Citation data={data} />
                        </Accordion>

                    </div>

                    <div className="resource-column-right">
                     	
                         
                         <a className={"btn green-bg full-width" + this.state.clicked}  onClick={this.onSave}>
	                        <span className="flag">{this.state.saveit}</span>
	                    </a>
	                    
	                     {data.catalog_url && 
                            <a
                                title="Go To Link"
                                className="resource-box-link btn full-width"
                                target="_blank"
                                href={ 
                                    !data.catalog_url.match(/^[a-zA-Z]+:\/\//) ?
                                        "//" + data.catalog_url : data.catalog_url }
                            >
                                Go To Resource
                            </a>
                        }
                        
                      
                        
                    </div>
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
