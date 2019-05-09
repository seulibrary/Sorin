const path = require("path")
const webpack = require("webpack")
const CopyWebpackPlugin = require("copy-webpack-plugin")
const TerserPlugin = require("terser-webpack-plugin")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")

const fs = require("fs")
let extension_list = fs.readdirSync(path.join(__dirname, "./js/extensions/"))

let config = {
    entry: [
        path.join(__dirname, "/js/index.js"),
        path.join(__dirname, "/scss/app.scss")
    ],
    output: {
        path: path.resolve(__dirname, "../priv/static/"),
        filename: "js/app.js"
    },
    resolveLoader: {
        modules: [path.join(__dirname, "node_modules")]
    },
    module: {
        rules: [
            {
                test: /\.(js|jsx)$/,
                exclude: /node_modules/,
                // include: path.join(__dirname, "assets/js"),
                use: {
                    loader: "babel-loader",
                    options: {
                        presets: ["@babel/preset-react", "@babel/preset-env"],
                        plugins: [
                            "@babel/plugin-proposal-object-rest-spread", 
                            "@babel/plugin-proposal-class-properties",
                            "@babel/plugin-syntax-dynamic-import"
                        ]
                    }
                }
            },
            {
                test: /\.(scss|css)$/,
                use: [
                    MiniCssExtractPlugin.loader,
                    {
                        loader: "css-loader",
                        options: {
                            url: false,
                        }
                    }, {
                        loader: "postcss-loader"
                    }, {
                        loader: "sass-loader"
                    }]
            },
            {
                test: /\.(png|woff|woff2|eot|ttf|svg)$/,
                use: [
                    {
                        loader: "url-loader",
                        options: {
                            limit: 10000
                        }
                    }
                ]
            }
        ]
    },
    plugins: [
        new MiniCssExtractPlugin({
            filename: "css/app.css",
        }),
        // Add this plugin so Webpack won't output the files when anything errors
        // during the build process
        new webpack.NoEmitOnErrorsPlugin(),
        new webpack.DefinePlugin({
            EXTERNAL_EXTENSIONS: JSON.stringify(extension_list)
        }),
        new CopyWebpackPlugin([
            { from: path.resolve(__dirname, "static/images"), to: "../static/images" },
            { from: path.resolve(__dirname, "static/favicon"), to: "../static/favicon" },
            { from: path.resolve(__dirname, "static/favicon.ico"), to: "../static/favicon.io" },
            { from: path.resolve(__dirname, "static/robots.txt"), to: "../static/robots.txt" }
        ]),
    ]
}

module.exports = (env, argv) => {
    if (argv.mode != "production") {
        config.mode = "development"
        config.devtool = "source-map"
        config.watchOptions = {
            poll: 1000,
            ignored: /node_modules/
        }

        config.optimization = {
            minimize: false,

            minimizer: [
                new TerserPlugin({
                    terserOptions: {
                        parallel: true,
                        ecma: 6,
                        compress: false,
                        output: {
                            comments: false,
                            beautify: false
                        }
                    }
                })
            ],
        }
    }

    if (argv.mode === "production") {
        config.mode = "production"
        config.devtool = false

        config.optimization = {
            minimize: true, 

            minimizer: [
                new TerserPlugin({
                    terserOptions: {
                        parallel: true,
                        ecma: 6,
                        compress: true,
                        output: {
                            comments: false,
                            beautify: false
                        }
                    }
                })
            ],
            splitChunks: {
                cacheGroups: {
                    styles: {
                        name: "app",
                        test: /\.css$/,
                        chunks: "all",
                        enforce: true
                    }
                }
            }
        }
    }

    return config
}