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
import SearchFilterButton from "../../components/SearchFilter/searchFilterButton"

class Search extends Component {
    componentDidMount() {
        if (this.props.hasOwnProperty("location")) {
            if (this.props.location && !this.props.loginPrompt) {
                var params = new URLSearchParams(this.props.location.search)

                var offset = params.get("offset") ? params.get("offset") : 0
                
                if (params.get("query") != null && params.get("query") != this.props.search.query) {
                    
                    this.props.dispatch({
                        type: Constants.SEARCH,
                        payload: params.get("query")
                    })

                    this.props.dispatch({
                        type: Constants.SET_SEARCH_OFFSET,
                        payload: parseInt(offset)
                    })
                
                    if (params.get("filters")) {
                        // parse filters into redux
                        let searchFilters = this.parseParams(
                            decodeURI(
                                params.get("filters")
                            )
                        )

                        this.props.dispatch({
                            type: Constants.SET_SEARCH_FILTERS,
                            payload: searchFilters
                        })

                        if (searchFilters.hasOwnProperty("preSearchType")) {
                            this.handleSearchView(searchFilters.preSearchType)
                        }
                    }
                    
                    this.props.dispatch(
                        search(
                            params.get("query"), 
                            this.props.location.search,
                            this.props.searchFilters.searchFilters
                        )
                    )
                }
            }
        }
        this.updateWindowDimensions()
        window.addEventListener("resize", this.updateWindowDimensions)
      }

    parseParams = (url) => {
        var hash;
        var myJson = {};
        var cleanUrl = url.replace('[', '').replace('%5B').replace(']', '').replace('%5D', '')

        var hashes = cleanUrl.slice(cleanUrl.indexOf('?') + 1).split('&');
        for (var i = 0; i < hashes.length; i++) {
            hash = hashes[i].split('=');
            var value = hash[1]
            // convert string bool to bool
            value = value == 'true' ? true : value
            value = value == 'false' ? false : value

            myJson[hash[0]] = value
        }

        return myJson
    }

    componentWillUnmount() {
        window.removeEventListener("resize", this.updateWindowDimensions)
    }
	
    updateWindowDimensions = () => {
        let header = document.getElementById("header")
        let tabs = document.getElementById("tabs")
        let search = document.getElementById("search")

        if (search && header != null && tabs != null) {
            search.style.height = ( window.innerHeight - (  header.offsetHeight + tabs.offsetHeight )) + "px"
        }
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
            // build url
            let params = '?query='+this.props.search.query

            let filters = this.props.searchFilters.searchFilters

            // check for search filters
            if (this.props.searchFilters.hasOwnProperty("searchFilters")) {
                params +=  "&filters=%5B" + Object.keys(filters).map(function(k) {
                    return encodeURIComponent(k) + '=' + encodeURIComponent(filters[k])
                }).join('%26') + "%5D"
            }
            
            this.props.history.push("/search" + params)
            
            // Make sure offset is reset to 0 in redux for new search
            this.props.dispatch({
                type: Constants.RESET_SEARCH_OFFSET
            })

            this.props.dispatch(search(this.props.search.query, params, this.props.searchFilters.searchFilters))
        }
    }

    loadMore = (e) => {
        e.preventDefault()

        let params = '?query=' + this.props.search.query + "&offset=" + this.props.search.searchOffset

        let filters = this.props.searchFilters.searchFilters

        if (this.props.searchFilters.hasOwnProperty("searchFilters")) {
            params +=  "&filters=%5B" + Object.keys(filters).map(function(k) {
                return encodeURIComponent(k) + '=' + encodeURIComponent(filters[k])
            }).join('%26') + "%5D"
        }
        
        window.history.pushState("", "SORIN SEACH", "/search" + params)
        this.props.dispatch(searchAppend(this.props.search.query, params,
            this.props.searchFilters, "catalog"))
    }

    loadMoreUsers = (e) => {
        e.preventDefault()
               
        let params = '?query=' + this.props.search.query + "&offset=" + this.props.search.searchOffset

        let filters = this.props.searchFilters.searchFilters

        if (this.props.searchFilters.hasOwnProperty("searchFilters")) {
            params +=  "&filters=%5B" + Object.keys(filters).map(function(k) {
                return encodeURIComponent(k) + '=' + encodeURIComponent(filters[k])
            }).join('%26') + "%5D"
        }
        
        this.props.history.push("/search" + params)
        
        this.props.dispatch(searchAppend(this.props.search.query, params,
            this.props.searchFilters, "users"))
    }

    loadMoreCollections = (e) => {
        e.preventDefault()

        let params = '?query=' + this.props.search.query + "&offset=" + this.props.search.searchOffset

        let filters = this.props.searchFilters.searchFilters

        if (this.props.searchFilters.hasOwnProperty("searchFilters")) {
            params +=  "&filters=%5B" + Object.keys(filters).map(function(k) {
                return encodeURIComponent(k) + '=' + encodeURIComponent(filters[k])
            }).join('%26') + "%5D"
        }

        this.props.history.push("/search" + params)

        this.props.dispatch(searchAppend(this.props.search.query, params,
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

                var params = new URLSearchParams(this.props.location.search)
                var offset = params.get("offset") ? parseInt(params.get("offset")) : 0
        
                return (
                    <div>
                        {searchresults.results.map((data, index) => {
                            let index_offset = index + offset

                            if (_.isEmpty(data)) {
                                return null
                            }
                            
                            return (
                                <SearchResult key={"search-result-" + index_offset} data={data} index={index_offset} />
                            )
                        })}
                        <Loader isVisible={this.props.search.searchLoading} />
                        {showLoadMoreResults ? 
                        <span onClick={this.loadMore} id="load-more" >Load More</span>
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
                var params = new URLSearchParams(this.props.location.search)
                var offset = params.get("offset") ? parseInt(params.get("offset")) : 0
        
                if (users.num_results === 0){
                    return (
                        <div>Sorry, no results found.</div>
                    )
                }

                if (users.results.length === 0) {
                    return (
                        <div>Sorry, you need to be logged in to view user results.</div>
                    )
                }

                return(
                    <div>
                        { users.results.map((data, index) => {
                            let index_offset_users = index + offset

                            return (
                                <CollectionResult key={"user-results" + index_offset_users} data={data} index={index_offset_users} />
                            )
                        })}
                        <Loader isVisible={this.props.search.searchLoading} />
                        {showLoadMoreUsers ? 
                            <span onClick={this.loadMoreUsers} id="load-more">Load More</span>
                            : "" }
                    </div>
                )
            } else {
                return <Loader isVisible={this.props.search.searchLoading} />
            }
        }
        case "collections": {
            let user_collections = this.props.search.searchResults.collections ? this.props.search.searchResults.collections : null
            var params = new URLSearchParams(this.props.location.search)
            var offset = params.get("offset") ? parseInt(params.get("offset")) : 0
    
            if (user_collections) {
                let showLoadMoreCollections = (this.props.search.searchOffset < user_collections.num_results)

                if (user_collections.num_results === 0) {
                    return (
                        <div>Sorry, no results found.</div>
                    )
                }

                if (user_collections.results.length === 0) {
                    return (
                        <div>Sorry, you need to be logged in to view collection results.</div>
                    )
                }

                return (
                    <div>
                        { user_collections.results.map((data, index) => {
                            let index_offset_collections = index + offset

                            return (
                                <CollectionResult key={"collections-results-" + index_offset_collections} data={data} index={index_offset_collections} />
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
                    
                    <SearchFilterButton />

                    <select 
                        id="search-dropdown" 
                        value={this.props.searchFilters.searchFilters.preSearchType}
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
            searchFilters: state.searchFilters,
            session: state.session
        }
    },
    function mapDispatchToProps(dispatch) {
        return {
            dispatch
        }
    }
)(Search)
