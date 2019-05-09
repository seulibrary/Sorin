import React, { Component } from "react"
import { connect } from "react-redux"
import Loader from "../../components/Loader"
import SearchResult from "../../components/SearchResult"
import CollectionResult from "../../components/SearchResult/collection"
import {search,
    searchAppend,
    setQuery,
    searchReset,
    switchView,
    setFilters
} from "../../actions/search"
import Constants from "../../constants"
import ErrorBoundary from "../Errors"
import SearchFilter from "../../components/SearchFilter"

class Search extends Component {
    componentDidMount() {
        this.updateWindowDimensions()
        window.addEventListener("resize", this.updateWindowDimensions)
    }

    componentWillUnmount() {
        window.removeEventListener("resize", this.updateWindowDimensions)
    }
	
    updateWindowDimensions = () => {
        document.getElementById("search").style.height = ( window.innerHeight - (  document.getElementById("header").offsetHeight + document.getElementById("tabs").offsetHeight )) + "px"
    }

    onQueryChange = (e) => {
        this.props.dispatch(setQuery(
            e.target.value
        ))
    }

    handleSearchView = (val) => {
        this.props.dispatch(switchView(
            {
                view: val,
            }
        ))
    }

    handleSearch = (e) => {
        this.props.dispatch({
            type: Constants.SEARCH,
            payload: e.target.value
        })
    }

    handleSearchReset = () => {
        this.props.dispatch(searchReset())
    }

    handleSearchType = (e) => {
        this.props.dispatch(
            setFilters({
                [e.target.name]: e.target.value
            })
        )
    }

    handleSubmit = (e) => {
        e.preventDefault()
        // if old results, clear search state, but leave filters
        if (this.props.search.searchResults.catalogs || this.props.search.searchResults.collections || this.props.search.searchResults.users) {
            this.props.dispatch({type: Constants.SEARCH_RESET})
        }
        // make sure there is actually content in search
        if (this.props.search.query.trim().length != 0) {
            this.props.dispatch(search(this.props.search.searchChannel, this.props.search.query, this.props.search, this.props.searchFilters.searchFilters))
        }
    }

    loadMore = (e) => {
        e.preventDefault()
        this.props.dispatch(searchAppend(this.props.search.searchChannel, this.props.search.query, this.props.search,
            this.props.searchFilters, "catalog"))
    }

    loadMoreUsers = (e) => {
        e.preventDefault()
        this.props.dispatch(searchAppend(this.props.search.searchChannel, this.props.search.query, this.props.search,
            this.props.searchFilters, "users"))
    }

    loadMoreCollections = (e) => {
        e.preventDefault()
        this.props.dispatch(searchAppend(this.props.search.searchChannel, this.props.search.query, this.props.search,
            this.props.searchFilters, "collections"))
    }

    loadResults = () => {
        switch(this.props.search.searchView) {
        case "catalog": {
            const searchresults = this.props.search.searchResults.catalogs ? this.props.search.searchResults.catalogs : null

            if (searchresults){
                let showLoadMoreResults = (this.props.search.searchOffset < searchresults.num_results)

                if (searchresults.num_results === 0) {
                    return (
                        <div>Sorry, no results found.</div>
                    )
                }
                return (
                    <div>
                        {searchresults.results.map((data, index) => {
                            return (
                                <SearchResult key={"search-result-" + index} data={data} index={index} />
                            )
                        })}
                        <Loader isVisible={this.props.search.searchLoading} />
                        {showLoadMoreResults ? 
                            <button onClick={this.loadMore} name="catalog" id="load-more">Load More</button>
                            : "" }
                    </div>
                )
            } else {
                return <Loader isVisible={this.props.search.searchLoading} />
            }
        }
        case "users": {
            let users = this.props.search.searchResults.users ? this.props.search.searchResults.users : null

            if (users) {
                let showLoadMoreUsers = (this.props.search.searchOffset < users.num_results)

                if (users.num_results === 0){
                    return (
                        <div>Sorry, no results found.</div>
                    )
                }

                return(
                    <div>
                        { users.results.map((data, index) => {
                            return (
                                <CollectionResult key={"user-results" + index} data={data} index={index} />
                            )
                        })}
                        <Loader isVisible={this.props.search.searchLoading} />
                        {showLoadMoreUsers ? 
                            <button onClick={this.loadMoreUsers} id="load-more">Load More</button>
                            : "" }
                    </div>
                )
            } else {
                return <Loader isVisible={this.props.search.searchLoading} />
            }
        }
        case "collections": {
            let user_collections = this.props.search.searchResults.collections ? this.props.search.searchResults.collections : null

            if (user_collections) {
                let showLoadMoreCollections = (this.props.search.searchOffset < user_collections.num_results)

                if (user_collections.num_results === 0) {
                    return (
                        <div>Sorry, no results found.</div>
                    )
                }

                return (
                    <div>
                        { user_collections.results.map((data, index) => {
                            return (
                                <CollectionResult key={"collections-results-" + index} data={data} index={index} />
                            )
                        })}
                        <Loader isVisible={this.props.search.searchLoading} />
                        {showLoadMoreCollections ? 
                            <button onClick={this.loadMoreCollections} id="load-more">Load More</button>
                            : "" }
                    </div>
                )
            } else {
                return <Loader isVisible={this.props.search.searchLoading} />
            }
        }
        default:
            return null
        }
    }
    
    render() {
        return (
            <div id="search">
                <form id="search-field" onSubmit={this.handleSubmit}>
                    <input type="text"  id="search-main" placeholder="Search Library Item or User" onChange={this.handleSearch} value={this.props.search.query} />

                    <select 
                        id="search-dropdown" 
                        defaultValue={this.props.searchFilters.preSearchType}
                        onChange={this.handleSearchType}
                        name="preSearchType">
                        <option value="catalog">Library Search</option>
                        <option value="users">Users</option>
                        <option value="collections">Collections</option>
                    </select>

                    <input type="submit" id="search-submit-btn" onClick={this.handleSubmit} />
                    
                    <div id="reset-search">
                        <span onClick={this.handleSearchReset}>Reset Search</span>
                    </div>

                    <SearchFilter onSumbit={this.handleSubmit} />
                </form>
                
                <div className="results-tab">
                    <span 
                        onClick={() => this.handleSearchView("catalog")} 
                        data-name="catalog" 
                        className={"results-tab " + (this.props.search.searchView == "catalog" ? "selected" : "")}>
                        Resources&nbsp;
                        <em>
                        ({this.props.search.searchResults.hasOwnProperty("catalogs") ? this.props.search.searchResults.catalogs.num_results : 0})
                        </em> 
                    </span> 
                    <span 
                        onClick={() => this.handleSearchView("users")} 
                        data-name="users" 
                        className={"results-tab " + (this.props.search.searchView == "users" ? "selected" : "")}>
                        Users&nbsp;
                        <em>
                        ({this.props.search.searchResults.hasOwnProperty("users") ? this.props.search.searchResults.users.num_results : 0})
                        </em>
                    </span> 
                    <span 
                        onClick={() => this.handleSearchView("collections")} 
                        data-name="collections" 
                        className={"results-tab " + (this.props.search.searchView == "collections" ? "selected" : "")}>
                        Collections 
                        <em>
                        ({this.props.search.searchResults.hasOwnProperty("collections") ? this.props.search.searchResults.collections.num_results : 0})
                        </em> 
                    </span>
                </div>

                <div className="results">
                    <ErrorBoundary>
                        { this.loadResults() }
                    </ErrorBoundary>
                </div>
            </div>
        )
    }
}

export default connect(
    function mapStateToProps(state) {
        return {
            search: state.search,
            searchFilters: state.searchFilters
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Search)
