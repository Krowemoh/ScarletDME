#include <stdlib.h>
#include <zig_ssl_config.h>
#include <mbedtls/ssl.h>

int zmbedtls_ssl_config_defaults(void * data, int endpoint, int proto, int presets) {
	mbedtls_ssl_config * conf = (struct mbedtls_ssl_config *)data;

	int ret = mbedtls_ssl_config_defaults(
		conf,
		endpoint,
		proto,
		presets
	);

	return ret;
}

void zmbedtls_ssl_config_free(void * data) {
	free(data);
}

void zmbedtls_ssl_config_init(void * data) {
	mbedtls_ssl_config * conf = (struct mbedtls_ssl_config *)data;

	mbedtls_ssl_config_init(conf);
}

void * zmbedtls_ssl_config_alloc() {
	mbedtls_ssl_config * conf = NULL;

	conf = malloc(sizeof(struct mbedtls_ssl_config));
	return conf;
}
