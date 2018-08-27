var entities =
[{
  "id": 1,
  "typeString": "struct",
  "properties": [
    {
  "name": "var isLoading",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var page: Int",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var errorMessage:String?",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var property: HomePropertyState",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "HomeState",
  "superClass": 16
},{
  "id": 2,
  "typeString": "struct",
  "properties": [
    {
  "name": "var account:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var portrait:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var allAssets:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var balance:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var CNY:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var recentRefundAsset:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var refundTime:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var cpuValue:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var netValue:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var ramValue:String",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var cpuProgress: Float",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var netProgress: Float",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var ramProgress: Float",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "AccountViewModel"
},{
  "id": 3,
  "typeString": "struct",
  "properties": [
    {
  "name": "var account:String",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "AccountListViewModel"
},{
  "id": 4,
  "typeString": "struct",
  "properties": [
    {
  "name": "var info:BehaviorRelay<AccountViewModel>",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var CNY_price:String",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "HomePropertyState"
},{
  "id": 5,
  "typeString": "struct",
  "properties": [
    {
  "name": "var balance:JSON?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "BalanceFetchedAction",
  "superClass": 17
},{
  "id": 6,
  "typeString": "struct",
  "properties": [
    {
  "name": "var info:Account?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "AccountFetchedAction",
  "superClass": 17
},{
  "id": 7,
  "typeString": "struct",
  "properties": [
    {
  "name": "var price:JSON?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "RMBPriceFetchedAction",
  "superClass": 17
},{
  "id": 8,
  "typeString": "class",
  "name": "HomePropertyActionCreate"
},{
  "id": 9,
  "typeString": "protocol",
  "methods": [
    {
  "name": "pushPaymentDetail()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushPayment()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushWallet()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushAccountList()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushResourceMortgageVC()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushBackupVC()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushBuyRamVC()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushVoteVC()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushDealRAMVC()",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "HomeCoordinatorProtocol"
},{
  "id": 10,
  "typeString": "protocol",
  "properties": [
    {
  "name": "var state: HomeState",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "subscribe<SelectedState, S: StoreSubscriber>( _ subscriber: S, transform: ((Subscription<HomeState>) -> Subscription<SelectedState>)? ) where S.StoreSubscriberStateType == SelectedState",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "getAccountInfo(_ account:String)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "createDataInfo() -> [LineView.LineViewModel]",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "checkAccount(_ completion:@escaping ResultCallback)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "HomeStateManagerProtocol"
},{
  "id": 11,
  "typeString": "class",
  "properties": [
    {
  "name": "var creator",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var store",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "HomeCoordinator",
  "superClass": 18,
  "extensions": [
    12,
    13
  ]
},{
  "id": 14,
  "typeString": "class",
  "properties": [
    {
  "name": "var tableView: UITableView!",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var tableHeaderView: HomeHeaderView!",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var headImageView: UIImageView?",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var coordinator: (HomeCoordinatorProtocol & HomeStateManagerProtocol)?",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "var data : Any?",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "viewDidLoad()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "refreshViewController()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "setupBgImage()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "viewWillAppear(_ animated: Bool)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "viewWillDisappear(_ animated: Bool)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "setupUI()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "updateUI()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "rightAction(_ sender: UIButton)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "configureObserveState()",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "name": "HomeViewController",
  "superClass": 19,
  "extensions": [
    15
  ]
},{
  "id": 16,
  "typeString": "class",
  "name": "StateType"
},{
  "id": 17,
  "typeString": "class",
  "name": "Action"
},{
  "id": 18,
  "typeString": "class",
  "name": "HomeRootCoordinator"
},{
  "id": 19,
  "typeString": "class",
  "name": "BaseViewController"
},{
  "id": 20,
  "typeString": "protocol",
  "name": "UITableViewDataSource"
},{
  "id": 21,
  "typeString": "protocol",
  "name": "UITableViewDelegate"
},{
  "id": 12,
  "typeString": "extension",
  "methods": [
    {
  "name": "pushBackupVC()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushAccountList()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushPaymentDetail()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushPayment()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushWallet()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushResourceMortgageVC()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushBuyRamVC()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushVoteVC()",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "pushDealRAMVC()",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    9
  ]
},{
  "id": 13,
  "typeString": "extension",
  "properties": [
    {
  "name": "var state: HomeState",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "methods": [
    {
  "name": "subscribe<SelectedState, S: StoreSubscriber>( _ subscriber: S, transform: ((Subscription<HomeState>) -> Subscription<SelectedState>)? ) where S.StoreSubscriberStateType == SelectedState",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "getAccountInfo(_ account:String)",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "createDataInfo() -> [LineView.LineViewModel]",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "checkAccount(_ completion:@escaping ResultCallback)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    10
  ]
},{
  "id": 15,
  "typeString": "extension",
  "methods": [
    {
  "name": "tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell",
  "type": "instance",
  "accessLevel": "internal"
},
    {
  "name": "tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)",
  "type": "instance",
  "accessLevel": "internal"
}
  ],
  "protocols": [
    20,
    21
  ]
}]
;

var renderedEntities = [];

var useCentralNode = true;

var templates = {
  case: undefined,
  property: undefined,
  method: undefined,
  entity: undefined,
  data: undefined,

  setup: function() {
    this.case = document.getElementById("case").innerHTML;
    this.property = document.getElementById("property").innerHTML;
    this.method = document.getElementById("method").innerHTML;
    this.entity = document.getElementById("entity").innerHTML;
    this.data = document.getElementById("data").innerHTML;

    Mustache.parse(this.case)
    Mustache.parse(this.property);
    Mustache.parse(this.method);
    Mustache.parse(this.entity);
    Mustache.parse(this.data);
  }
}

var colorSuperClass = { color: "#848484", highlight: "#848484", hover: "#848484" }
var colorProtocol = { color: "#9a2a9e", highlight: "#9a2a9e", hover: "#9a2a9e" }
var colorExtension = { color: "#2a8e9e", highlight: "#2a8e9e", hover: "#2a8e9e" }
var colorContainedIn = { color: "#99AB22", highlight: "#99AB22", hover: "#99AB22" }
var centralNodeColor = "rgba(0,0,0,0)";
var centralEdgeLengthMultiplier = 1;
var network = undefined;

function bindValues() {
    templates.setup();

    for (var i = 0; i < entities.length; i++) {
        var entity = entities[i];
        var entityToBind = {
            "name": entity.name == undefined ? entity.typeString : entity.name,
            "type": entity.typeString,
            "props": renderTemplate(templates.property, entity.properties),
            "methods": renderTemplate(templates.method, entity.methods),
            "cases": renderTemplate(templates.case, entity.cases)
        };
        var rendered = Mustache.render(templates.entity, entityToBind);
        var txt = rendered;
        document.getElementById("entities").innerHTML += rendered;
    }

    setSize();
    setTimeout(startCreatingDiagram, 100);
}

function renderTemplate(template, list) {
    if (list != undefined && list.length > 0) {
        var result = "";
        for (var i = 0; i < list.length; i++) {
            var temp = Mustache.render(template, list[i]);
            result += temp;
        }
        return result;
    }
    return undefined;
}

function getElementSizes() {
  var strings = [];
  var elements = $("img");

  for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      
      var elementData = {
        width: element.offsetWidth,
        height: element.offsetHeight
      };
      strings.push(elementData);
  }
  return strings;
}

function renderEntity(index) {
  if (index >= entities.length) {
    // create the diagram
    $("#entities").html("");
    setTimeout(createDiagram, 100);
    return;
  }
  html2canvas($(".entity")[index], {
    onrendered: function(canvas) {
      var data = canvas.toDataURL();
      renderedEntities.push(data);
      var img = Mustache.render(templates.data, {data: data}); 
      $(document.body).append(img);

      renderEntity(index + 1);
    }
  });
}

function startCreatingDiagram() {
  renderedEntities = [];
  renderEntity(0);
}

function createDiagram() {
  var entitySizes = getElementSizes();

  var nodes = [];
  var edges = [];

  var edgesToCentral = [];
  var maxEdgeLength = 0;
  for (var i = 0; i < entities.length; i++) {
    var entity = entities[i];
    var data = entitySizes[i];
    var length = Math.max(data.width, data.height) * 1.5;
    var hasDependencies = false;

    maxEdgeLength = Math.max(maxEdgeLength, length);

    nodes.push({id: entity.id, label: undefined, image: renderedEntities[i], shape: "image", shapeProperties: {useImageSize: true } });
    if (entity.superClass != undefined && entity.superClass > 0) {
      edges.push({from: entity.superClass, to: entity.id, length: length, color: colorSuperClass, label: "inherits", arrows: {from: true} });
      
      hasDependencies = true;
    }

    var extEdges = getEdges(entity.id, entity.extensions, length, "extends", colorExtension, {from: true});
    var proEdges = getEdges(entity.id, entity.protocols, length, "conforms to", colorProtocol, {to: true});
    var conEdges = getEdges(entity.id, entity.containedEntities, length, "contained in", colorContainedIn, {from: true});

    hasDependencies = hasDependencies && extEdges.length > 0 && proEdges.length > 0 && conEdges.length > 0;

    edges = edges.concat(extEdges);
    edges = edges.concat(proEdges);
    edges = edges.concat(conEdges);

    if (!hasDependencies && useCentralNode)
    {
      edgesToCentral.push({from: entity.id, to: -1, length: length * centralEdgeLengthMultiplier, color: centralNodeColor, arrows: {from: true} });
    }
  }

  if (edgesToCentral.length > 1) {
    edges = edges.concat(edgesToCentral);
    nodes.push({id: -1, label: undefined, shape: "circle", color: centralNodeColor });
  }

  var container = document.getElementById("classDiagram");
  var dataToShow = {
      nodes: nodes,
      edges: edges
  };
  var options = {
      "edges": { "smooth": false },
      "physics": {
        "barnesHut": {
          "gravitationalConstant": -7000,
          "springLength": maxEdgeLength,
          "avoidOverlap": 1
        }
      },
      //configure: true
  };
  network = new vis.Network(container, dataToShow, options);

  $("#entities").html("");
  $("img").remove();

  setTimeout(disablePhysics, 200);
}

function disablePhysics()
{
  var options = {
      "edges": { "smooth": false },
      "physics": { "enabled": false }
  };
  network.setOptions(options);
  $(".loading-overlay").fadeOut("fast");
}

function getEdges(entityId, arrayToBind, edgeLength, label, color, arrows) {
  var result = [];
  if (arrayToBind != undefined && arrayToBind.length > 0) {
      for (var i = 0; i < arrayToBind.length; i++) {
        result.push({from: entityId, to: arrayToBind[i], length: edgeLength, color: color, label: label, arrows: arrows });
      }
  }
  return result;   
}

function setSize() {
  var width = $(window).width();
  var height = $(window).height();

  $("#classDiagram").width(width - 5);
  $("#classDiagram").height(height - 5);
}