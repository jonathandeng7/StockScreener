# Stock Screener

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

A mobile stock screener app that allows users to view live or recent market data for specific tickers. Users can search for stocks, view line or candlestick charts, and filter results by customizable time frames (1D, 1W, 1M, 3M, 1Y, 5Y, MAX). The app will also allow quick access to basic stock information such as price, volume, percentage change, and moving averages.

### App Evaluation

[Evaluation of your app across the following attributes]
- **Category:** Finance / Productivity
- **Mobile:** Optimized for mobile with smooth, touch-enabled chart navigation, pull-to-refresh for latest data, and swipe gestures to switch between time frames or tickers.
- **Story:** Empowers investors and traders to make quick, informed decisions by providing visual and customizable stock performance data on the go.
- **Market:** Retail investors, finance enthusiasts, and anyone tracking the stock market. Large market due to growing interest in personal investing and trading.
- **Habit:** Users may open the app multiple times per day to check live prices, compare stock performance, and track trends.
- **Scope:** MVP includes ticker search, chart display, and time frame switching. Extended features can add watchlists, indicators (RSI, MACD), and push notifications for price alerts.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**  
 User can search for a stock by ticker symbol.

 User can view a line or candlestick chart for a selected ticker.

 User can switch between time frames (1D, 1W, 1M, 3M, 1Y, 5Y, MAX).

 User can see basic stock stats: current price, % change, volume.

 Smooth, responsive chart zoom and pan gestures.


**Optional Nice-to-have Stories**

 Add technical indicators (RSI, MACD, SMA).

 Allow creation of a personal watchlist.

 Push notifications for price targets or alerts.

 Dark/light mode toggle.

### 2. Screen Archetypes

- [ ] [Search Screen]
* User can input a stock ticker symbol.
* Displays list of matching stocks and quick stats.
[Chart Screen]
Displays line or candlestick chart for selected ticker.

Time frame selector at the top.

Quick stats panel showing price, change %, volume.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Search
* Chart

**Flow Navigation** (Screen to Screen)

Search Screen → Chart Screen (on ticker select)


## Wireframes

[Add picture of your hand sketched wireframes in this section]
![IMG_4544](https://github.com/user-attachments/assets/57ddb517-3c18-41d0-8178-9620c6a6042b)


### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 

[This section will be completed in Unit 9]

### Models

[Add table of models]

### Networking

- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
