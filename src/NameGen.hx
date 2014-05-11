import haxe.ds.StringMap;

class MarkovNode {
    public var data:String = null;
    var count:Int = 0;
    var prob:Float = 0;
    var children:StringMap<MarkovNode> = new StringMap<MarkovNode>();

    public function new(?data:String){
        this.data = data;
    }

    public function createOrIncrementChild(data:String) : MarkovNode {
        if(!children.exists(data)){
            children.set(data, new MarkovNode(data));
        }

        var child = children.get(data);
        ++child.count;

        recalcProbs();

        return child;
    }

    private function recalcProbs() : Void {
        var total = 0;
        var prob = 0.0;

        for(child in children){
            total += child.count;
        }

        for(child in children){
            prob += child.count / total;
            child.prob = prob;
        }
    }

    public function getRandomNode(){
        var rnd = Math.random();
        var node = null;

        for (child in children){
            if(node == null){
                node = child;
            }

            if((node.prob < child.prob && child.prob <= rnd) ||
               (child.prob == 1 && rnd > node.prob)){
                node = child;
            }
        }

        return node;
    }
}

class NameGen {
    var root = new MarkovNode();

    public function new(names:Array<String>){
        for(name in names){
            parseName(root, name.toLowerCase());
        }
    }

    public function generateName(){
        var length = Std.random(6) + 3;
        var name = "";

        var current = root.getRandomNode();

        while(name.length < length && current != null){
            name += current.data;
            current = current.getRandomNode();
        }

        return name;
    }

    private function parseName(root:MarkovNode, name:String):Void {
        if(name.length <= 1) return;

        var node = root;

        for(char in 0 ... name.length){
            node = node.createOrIncrementChild(name.charAt(char));
        }
    }
}
