# ClickHouse for Solana Analytics Demo

> 🚀 Transform hours of blockchain queries into milliseconds with ClickHouse

This repository contains demo queries and documentation for showcasing ClickHouse's capabilities for Solana blockchain analytics at the Solana Summit APAC 2025, Da Nang, Vietnam.

## 📊 The Challenge

Solana processes up to **65,000 transactions per second**, generating approximately **400GB of data daily**. Traditional databases struggle with:

- ❌ Hour-long query times
- ❌ Expensive infrastructure costs
- ❌ Inability to handle real-time analytics
- ❌ Complex nested data structures

## 💡 The Solution: ClickHouse

ClickHouse is a columnar database designed for real-time analytics on massive datasets. For blockchain data, it provides:

- ✅ **100-1000x faster queries** than PostgreSQL
- ✅ **10-20x data compression**
- ✅ **5-10x lower infrastructure costs**
- ✅ **Sub-second query performance** on billions of rows

## 🎯 Demo Overview

This demo showcases 10 progressive queries that solve real Solana ecosystem challenges:

### Query Highlights

1. **Scale Overview** - Analyze billions of transactions instantly
2. **Network Health** - Real-time success rates and performance metrics
3. **Program Analytics** - Identify top programs and their compute efficiency
4. **Token Velocity** - Track token movements and liquidity patterns
5. **Whale Watching** - Detect large transfers as they happen
6. **Money Flow** - Understand value movement through the network
7. **Instant Dashboards** - Pre-aggregated views for zero-latency analytics
8. **Compute Optimization** - Profile program performance
9. **Congestion Analysis** - Identify network bottlenecks
10. **Performance Strategies** - Advanced optimization techniques

## 🚀 Getting Started

### Prerequisites

- Access to a [ClickHouse instance with Solana data](https://crypto.clickhouse.com/)
- Basic SQL knowledge
- Understanding of Solana's data model

### Running the Demo

1. Clone this repository
2. Access [CryptoHouse Demo Database](https://crypto.clickhouse.com/)
3. Run queries from `CryptoHouse_Demo.sql`
4. Note execution times for each query

### Data Note

The demo queries are configured for data up to `2025-05-20 20:00:51`. Adjust timestamps based on your dataset.

## 📈 Business Value & Use Cases

### For Validators

- **Network Monitoring**: Track success rates and identify issues in real-time
- **Performance Optimization**: Analyze compute patterns and optimize block production
- **Revenue Analysis**: Understand fee dynamics and MEV opportunities

### For DeFi Protocols

- **Liquidity Analytics**: Track token flows and identify arbitrage patterns
- **User Behavior**: Understand interaction patterns and optimize UX
- **Risk Management**: Detect unusual activities and potential exploits

### For Traders

- **Alpha Discovery**: Find patterns before they become mainstream
- **Whale Tracking**: Monitor large movements for market signals
- **MEV Analysis**: Identify profitable opportunities

### For NFT Projects

- **Mint Analytics**: Optimize launch timing based on network congestion
- **Holder Analysis**: Track distribution and identify whales
- **Market Trends**: Understand trading patterns

## 🔧 Key ClickHouse Features Used

### Performance Optimizations

- **PREWHERE**: Filters data before reading all columns
- **MaterializedViews**: Pre-aggregated data for instant dashboards
- **CTEs**: Common Table Expressions for query organization

### Data Handling

- **Array Functions**: Native support for Solana's nested structures
- **Compression**: 10-20x reduction in storage requirements
- **Parallel Processing**: Utilizes all CPU cores for maximum speed

## 📊 Performance Benchmarks

Based on real implementations:

- Query time: **100ms - 2s** (vs 30min - 2hrs in PostgreSQL)
- Data ingestion: **1M+ rows/second** per node
- Compression ratio: **15-20x** for Solana data
- Cost reduction: **80-90%** vs traditional data warehouses

## 💬 Common Questions

**Q: How real-time is the data?**
A: Sub-second ingestion latency. Queries see data within 1-2 seconds of block production.

**Q: Can it scale with Solana's growth?**
A: Yes, ClickHouse scales linearly. Add nodes for more performance.

**Q: What's the learning curve?**
A: If you know SQL, you can use ClickHouse. Advanced features are optional.

---

**Ready to supercharge your Solana analytics?** Start with these queries and unlock insights that were previously impossible.
