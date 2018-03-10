EXPERIMENT=$1

cl work main::cs224n-omelette-du-fromage
echo "Uploadin code"
cl upload code

echo "Uploading checkpoint"
cl upload experiments/$EXPERIMENT/best_checkpoint

echo "Creating predictions"
cl run --name gen-answers --request-docker-image abisee/cs224n-dfp:v4 \
 :code :best_checkpoint glove.txt:0x97c870/glove.6B.100d.txt data.json:0x8f29fe \
 'python code/main.py --model_name=bidaf --mode=official_eval --num_layers=2 --batch_size=32 \
 --glove_path=glove.txt --json_in_path=data.json --ckpt_load_dir=best_checkpoint'

cl wait --tail gen-answers

echo "Evaluating predictions\n"
cl run --name run-eval --request-docker-image abisee/cs224n-dfp:v4 \
:code data.json:0x4870af preds.json:gen-answers/predictions.json \
'
python code/evaluate.py data.json preds.json
'

cl wait --tail run-eval
