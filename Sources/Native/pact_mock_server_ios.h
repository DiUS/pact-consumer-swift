
#ifndef pact_mock_server_h
#define pact_mock_server_h

int32_t create_mock_server_ffi(const char *pact, int32_t port);
bool mock_server_matched_ffi(int32_t port);
const char *mock_server_mismatches_ffi(int32_t port);
bool cleanup_mock_server_ffi(int32_t port);
int32_t write_pact_file_ffi(int32_t port, const char *directory);

#endif /* pact_mock_server_h */
