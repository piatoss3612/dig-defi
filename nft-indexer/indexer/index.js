const { gql, request } = require("graphql-request");

const MY_NFT_QUERY_URL =
  "https://api.studio.thegraph.com/query/71401/mynft/version/latest";

const main = async () => {
  const query = gql`
    {
      transfers(first: 5) {
        from
        to
        tokenId
      }
    }
  `;
  const response = await request(MY_NFT_QUERY_URL, query);

  console.log(response);
};

main();
