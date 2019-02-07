use Mix.Config

config :kaltura_server, domain_model_handler: KalturaServer.Handlers.DomainModelHandler

config :kaltura_server, KalturaServer.RequestProcessing.MainRouter, port: [dev: 4001, test: 4003]
