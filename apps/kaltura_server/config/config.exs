use Mix.Config

config :kaltura_server, domain_model_handler: KalturaServer.Handlers.DomainModelHandler

config :kaltura_server, KalturaServer.RequestProcessing.MainRouter,
  http_port: [dev: 4001, test: 4003, prod: 81, stage: 81],
  https_port: [dev: 4040, test: 4041, prod: 443, stage: 443],
  https_keyfile: "priv/cert/selfsigned_key.pem",
  https_certfile: "priv/cert/selfsigned.pem"

config :plug, validate_header_keys_during_test: false
