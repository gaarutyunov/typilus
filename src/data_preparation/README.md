# Typilus Data Preparation

This image can be used to prepare repositories collected using [gh-exporter](https://github.com/gaarutyunov/gh-exporter) tool for ML model training.

## Usage

1. Pull the image:

```bash
docker pull germanarutyunov/typilus-env:latest
```

2. Run the full data processing script. Notice the volume mount that points to the local path where you cloned the repositories:

```bash
docker run -v /local/path/to/repos:/usr/data germanarutyunov/typilus-env:latest bash scripts/process_data.sh --add-raw-data --annotation-vocab-size 100 --model graph2hybridmetric
```

The script accepts the following options:

--pytype: adds types inferred by pytype to the source code (takes a long time)
--add-raw-data: adds raw graph data to the resulting graph tensors
--annotation-vocab-size: size of the type annotation vocabulary, i.e. the number of types recognized by the model
--model: the name of the Typilus model used to process the data

3. You can also run all the stages separately in interactive mode (see stages list and corresponding scripts below):

```bash
docker run -v /local/path/to/repos:/usr/data -it germanarutyunov/typilus-env:latest bash
```

## Stages

### Tokenization

This step is necessary for efficient code deduplication. It is done with the following script [scripts/tokenize_data.sh](https://github.com/gaarutyunov/typilus/blob/master/src/data_preparation/scripts/tokenize_data.sh).

### Deduplication

This is a very important step to avoid code duplication in train and test samples. The script is [scripts/deduplicate_data.sh](https://github.com/gaarutyunov/typilus/blob/master/src/data_preparation/scripts/deduplicate_data.sh).

### Adding types

During this step pytype is used to add types that can be added statically to the source code. This way the quality of the dataset is increased. The script is [scripts/pytype_data.sh](https://github.com/gaarutyunov/typilus/blob/master/src/data_preparation/scripts/pytype_data.sh).

If run from the [scripts/process_data.sh](https://github.com/gaarutyunov/typilus/blob/master/src/data_preparation/scripts/process_data.sh) the step is optional and will be executed only if the `--pytype` option is passed to the script.

### Graph extraction

Later the graphs are extracted using the typilus pipeline. The script is [scripts/extract_graphs.sh](https://github.com/gaarutyunov/typilus/blob/master/src/data_preparation/scripts/extract_graphs.sh).

### Data split

The data is then split into train, valid and test samples. The script is [scripts/split_data.sh](https://github.com/gaarutyunov/typilus/blob/master/src/data_preparation/scripts/split_data.sh).

### Conversion to tensors

The data split then can be converted into tensors that can be processed by the ML model. The script is [scripts/tensorise_data.sh](https://github.com/gaarutyunov/typilus/blob/master/src/data_preparation/scripts/tensorise_data.sh).

The script accepts three options:

--add-raw-data: adds raw graph data to the resulting graph tensors
--annotation-vocab-size: size of the type annotation vocabulary, i.e. the number of types recognized by the model
--model: the name of the Typilus model used to process the data