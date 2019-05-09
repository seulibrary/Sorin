import React, { Component } from "react"
import Accordion from "../../components/Accordion"

export default class About extends Component {
    constructor(props) {
        super(props)
    }

    render() {
        return (
            <div id="about">
                <div className="about-section">
                    <h1>About Sorin</h1>

                    <div id="youtube-sorin">
                        <iframe 
                            src="https://www.youtube.com/embed/aVIIiqC5JXU?rel=0" 
                            frameBorder="0"
                            allowFullScreen="allowFullScreen"></iframe>
                    </div>

                    <p>Academic library users today have access to a multitude of digital resources; however, the research tools they use do not always meet the needs of their workflows. The Munday Library seeks to transform the research process for the user through the development of a web application called Sorin that allows the user to Search, Organize, Research, and INteract with information in a more efficient and effective way. </p>

                    <p>The research process in Sorin begins with a simple search in a traditional library search bar; however, the results may be saved to an inbox. From this inbox, the user can organize saved items into collections, or curated lists of articles, books, or web links, that can be edited and annotated. Afterwards, the user can publish their collection in order to be searched and used by members of the campus community. Collections created in Sorin can be adapted to other tools and even shared with others who do not use the tool. </p>

                    <p>Sorin was developed by Munday Library staff after a series of interviews conducted with the faculty at St. Edward’s University in 2016. During this process, it became apparent that the university community needed a tool that would enhance the research experience for users from searching to storing content to sharing and collaboration. By developing an innovative web application with a simple, clean design for the St. Edward’s University community, the Munday Library fulfills its mission of supporting the discovery, analysis, and creation of knowledge. 
                    </p>
                </div>

                <div className="about-section">
                    <h2>Frequently Asked Questions</h2>

                    <Accordion title="How do I search and save library items?" symbolPosition="left">
                        <p> To search, put your cursor in the search bar in the “Search,” page, type in what you want to search for, and press Enter or click the magnifying lens. You can use the “Filter Search,” tab on the right to refine your query before or after searching.  </p>

                        <img src="/images/faq1Search.png" alt="search" />

                        <p> You can save resources by clicking the large green “SAVE IT!” button on the right side of search results. Whatever you save will be stored in the “Inbox,” collection in your Collections screen.</p>

                        <img src="/images/faq1Searchresults.jpg" alt="search results" />
                    </Accordion>

                    <Accordion title="How do I create a collection?" symbolPosition="left">
                        <p> Once you have logged in with your SEU Gmail account, click the large gray “Collections” bar in the upper right part of the screen, then click the blue “Create Collection,” button at the end of the row of your existing collections. You must supply a title, but the title can be changed at any time.</p>

                        <img src="/images/faq2createCollection.png" alt="Create Collection" />
                    </Accordion>

                    <Accordion title="How do I publish a collection?" symbolPosition="left">
                        <p> Open the collection’s menu by clicking the three dots in its top right corner, then expand the “Share” menu in the right sidebar and check the “PUBLISH” checkbox.</p>

                        <p> Note: once a collection has been published, it cannot be unpublished. To remove access to it, you will have to delete it. To keep your work, you can import the collection first by searching for it in the search bar and clicking “IMPORT,” which will give you a new, unpublished copy at the end of the row of your existing collections. Make sure to delete the original, not the import.
                        </p>

                        <img src="/images/faq3publishCollection.png" alt="Publish a collection" />	
                    </Accordion>

                    <Accordion title=" How do I search for a published collection?" symbolPosition="left">
                        <p> You can search for published collections from the main search bar in two ways:</p>

                        <ol>
                            <li>Enter your search terms, then click the drop-down menu at the right end of the search bar and select “Collections,” then click the magnifying lens.</li>
                            <li>Enter your search terms, press enter or click the magnifying lens, then click the small “Collections” tab between the search bar and the results area.</li>
                        </ol>

                        <img src="/images/faq4search.png" alt="Published collection" />	
                    </Accordion>

                    <Accordion title="What is the difference between cloning and importing a collection? " symbolPosition="left">
                        <p> When you <b>clone</b> a collection:</p>

                        <ul>
                            <li>Your copy of it will always be up to date with the original version</li>
                            <li>You will not be able to edit it in any way</li>
                            <li>If the original is deleted by its creator, you will lose access to it</li>
                        </ul>

                        <p> When you <b>import</b> a collection:</p>

                        <ul>
                            <li>Your copy will not stay in sync with the original: if the creator of the original makes any changes to it, you will not get those changes</li>
                            <li>The import will belong to you, and you will be able to edit it however you want</li>
                            <li>It will have a provenance line recording whom you imported it from and when</li>
                            <li>It can only be edited or deleted by you</li>
                        </ul>

                        <img src="images/faq5clone.png" alt="Cloning and importing" />
                    </Accordion>

                    <Accordion title="How does collection ownership work? Can someone else make significant changes to a collection I have created without my permission?" symbolPosition="left">
                        <p><b>A collection can only be edited by one person,</b> the person who created it. If the collection is published, it can be cloned by other people, who will then be able to see any changes made to it by its creator, but who will not be able to change it in any way. They can also import it, which makes them a new copy that they can make changes to, but the changes will not affect the original version.</p>
                    </Accordion>

                    <Accordion title="Will this platform work for students throughout their entire college career at this campus?" symbolPosition="left">
                        <p><b>Yes!</b> Anyone with a St. Edward’s Gmail account can log in to Sorin and create collections, and those collections will never be deleted unless you delete them. Any collections you still have when your account is closed will be available indefinitely at their permalink, unless you request them to be removed.
                        </p>
                    </Accordion>

                    <Accordion title="How can I be a part of the development process?" symbolPosition="left">
                        <p><b>Your feedback, bug reports, and ideas for future development are extremely appreciated.</b> The best way to provide feedback of any kind is with the “let us know” link in the header of the site, or, if you prefer, with the live chat widget also in the header.</p>
                        <p>During the spring of 2019, Sorin will also be open sourced. Pull requests and ticket submissions will be welcome from anyone.</p>
                    </Accordion>

                    <Accordion title="Can a librarian visit my class and teach this tool?" symbolPosition="left">
                        <p><b>Yes!</b> We would be happy to help with ideas and instruction. Please contact the library to discuss your ideas.</p>
                    </Accordion>

                    <Accordion title="How do I report issues with the tool?" symbolPosition="left">
                        <p>The fastest way to report an issue is with the “To give us feedback as we develop future versions of the tool click here” link near the top of the site. You can also use the “live chat” button to chat with librarians during open hours.</p>
                    </Accordion>

                    <Accordion title="How can I adopt this tool for my own university?" symbolPosition="left">
                        <p> During the spring of 2019, Sorin will be open sourced. We’re still working on the roadmap for that process, but we will be seeking co-maintainers and hope to build a developer community to work with us. </p>

                        <h4>Technical information</h4>

                        <p>Sorin is a web application the core of which is written in Elixir with the Phoenix web framework. Sorin currently supports Google accounts for authentication, Ex Libris’ Primo for catalog search, PostgreSQL for data, and React for the front end; but these are all isolated modules in the code base and it will be possible to develop modules for other catalogs, data stores, front ends (or client applications), and authentication systems.</p>

                        <p>For more information, contact rgibbs@stedwards.edu. </p>
                    </Accordion>
                </div>
            </div>
        )
    }
}
