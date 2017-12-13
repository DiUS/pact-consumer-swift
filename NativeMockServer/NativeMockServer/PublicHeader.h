
#ifndef PublicHeaders_h
#define PublicHeaders_h

int32_t create_mock_server(const char *pact, int32_t port);
bool mock_server_matched(int32_t port);
const char *mock_server_mismatches(int32_t port);
bool cleanup_mock_server(int32_t port);
int32_t write_pact_file(int32_t port, const char *directory);

#endif /* PublicHeaders_h */
