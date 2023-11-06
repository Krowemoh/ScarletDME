#ifndef ZIG_SSL_CONFIG_H
#define ZIG_SSL_CONFIG_H

struct zmbedtls_ssl_config {
    void * ssl_config;
};

int zmbedtls_ssl_config_defaults(void * data, int endpoint, int proto, int presets);
void zmbedtls_ssl_config_init(void * data);
void zmbedtls_ssl_config_free(void * data);
void * zmbedtls_ssl_config_alloc();

#endif
