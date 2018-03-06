MODEL_NAME=$1
EXPERIMENT_NAME=$2
BUNDLE_NAME=$3
cl work main::cs224n-omelette-du-fromage
echo "Uploadin code"
# cl upload code

echo "Uploading checkpoint"
# cl upload experiments/$EXPERIMENT_NAME/best_checkpoint

echo "Creating predictions"
cl run --name bidaf_test --request-docker-image abisee/cs224n-dfp:v4 \
 :code :best_checkpoint glove.txt:0x97c870/glove.6B.100d.txt data.json:0x4870af \
 'python code/main.py --model=bidaf --mode=official_eval \
 --glove_path=glove.txt --json_in_path=data.json --ckpt_load_dir=best_checkpoint'

cl wait --tail bidaf_test

echo "Evaluating predictions\n"
cl run --name run-eval --request-docker-image abisee/cs224n-dfp:v4 \
:code data.json:0x4870af preds.json:bidaf_test/predictions.json \
'
python code/evaluate.py data.json preds.json
'

cl wait --tail run-eval
cl cat run-eval/stdout