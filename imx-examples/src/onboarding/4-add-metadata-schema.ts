import { InfuraProvider } from '@ethersproject/providers';
import { Wallet } from '@ethersproject/wallet';
import { ImLogger, WinstonLogger } from '@imtbl/imlogging';
import {
  AddMetadataSchemaToCollectionParams,
  ImmutableXClient,
  MetadataTypes,
} from '@imtbl/imx-sdk';
import { requireEnvironmentVariable } from 'libs/utils';

import env from '../config/client';
import { loggerConfig } from '../config/logging';

const provider = new InfuraProvider(env.ethNetwork, env.alchemyApiKey);
const log: ImLogger = new WinstonLogger(loggerConfig);

const component = '[IMX-ADD-COLLECTION-METADATA-SCHEMA]';

(async (): Promise<void> => {
  const privateKey = requireEnvironmentVariable('OWNER_ACCOUNT_PRIVATE_KEY');
  const collectionContractAddress = requireEnvironmentVariable(
    'COLLECTION_CONTRACT_ADDRESS',
  );

  const wallet = new Wallet(privateKey);
  const signer = wallet.connect(provider);

  const user = await ImmutableXClient.build({
    ...env.client,
    signer,
    enableDebug: true,
  });

  log.info(
    component,
    'Adding metadata schema to collection',
    collectionContractAddress,
  );

  /**
   * Edit your values here
   */
  const params: AddMetadataSchemaToCollectionParams = {
    metadata: [
      {
        name: 'type',
        type: MetadataTypes.Enum,
        filterable: true,
      },
      {
        name: 'subtype',
        type: MetadataTypes.Enum,
        filterable: true,
      },
      {
        name: 'rarity',
        type: MetadataTypes.Enum,
        filterable: true,
      },
      {
        name: 'skin',
        type: MetadataTypes.Enum,
        filterable: true,
      },
      {
        name: 'style',
        type: MetadataTypes.Enum,
        filterable: true,
      },
      {
        name: 'health',
        type: MetadataTypes.Discrete,
        filterable: false,
      },
      {
        name: 'accuracy',
        type: MetadataTypes.Discrete,
        filterable: false,
      },
      {
        name: 'speed',
        type: MetadataTypes.Discrete,
        filterable: false,
      },
      {
        name: 'endurance',
        type: MetadataTypes.Discrete,
        filterable: false,
      },
      {
        name: 'strength',
        type: MetadataTypes.Discrete,
        filterable: false,
      },
      {
        name: 'level',
        type: MetadataTypes.Discrete,
        filterable: false,
      },
      {
        name: 'boost 1',
        type: MetadataTypes.Enum,
        filterable: true,
      },
      {
        name: 'boost 2',
        type: MetadataTypes.Enum,
        filterable: true,
      },
      // ..add rest of schema here
    ],
  };

  const collection = await user.addMetadataSchemaToCollection(
    collectionContractAddress,
    params,
  );

  log.info(
    component,
    'Added metadata schema to collection',
    collectionContractAddress,
  );
  console.log(JSON.stringify(collection, null, 2));
})().catch(e => {
  log.error(component, e);
  process.exit(1);
});
