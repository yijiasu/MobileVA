
function generate_data_for_people(number_of_people)
{
  // console.log("number:" + number_of_people);
  nodes_data = [];
  links_data = [];

  for (var i = 0; i < number_of_people ; i++)
  {
    nodes_data.push({id: "p" + i});
    // console.log(nodes_data);
    var degree_one_number = Math.floor(Math.random() * 3) + 1;
    for (var j = 0; j < degree_one_number; j++)
    {
      nodes_data.push({id: "p" + i + "." + j});
      links_data.push({source:"p" + i, target: "p" + i + "." + j});

      var degree_two_number = Math.floor(Math.random() * 3) + 1;

      for (var k = 0; k < degree_two_number; k++)
      {
        nodes_data.push({id: "p" + i + "." + j +  "." + k});
        links_data.push({source:"p" + i + "." + j, target: "p" + i + "." + j +  "." + k});
      }
    }
  }
  
  // link together
  for (var i = 0; i < number_of_people - 1 ; i++)
  {
    links_data.push({ source: "p" + i, target: "p" + (i + 1)});
  }
}

function update(json_data)
{
    var array = JSON.parse(json_data);
    // console.log(array);

    // generate_data_for_people(array.length);

    for (var i = 0; i < array.length; i++)
    {
      move("p" + i, array[i].x, array[i].y);
      resize("p" + i, array[i].r);
    }

    if (array.length == 3)
    {
      move("a", array[0].x, array[0].y);
      resize("a", array[0].r);
      move("b", array[1].x, array[1].y);
      resize("b", array[1].r);
      move("c", array[2].x, array[2].y);
      resize("c", array[2].r);

    }

    // move("a", array[0].x, array[0].y);
    // resize("a", array[0].r);
    // if (array.length == 2)
    // {
    //   move("b", array[1].x, array[1].y);
    //   resize("b", array[1].r);
    // }

}

function resize(id, r)
{
    _.each(nodes_data, function(d) {
    if (d.id == id) {
           d.r = r;
           restart();
    }
    });
    _.each(links_data, function(d){
   if (d.id == id) {
           d.distance = r + 20;
           restart();
   }
           
   });

}
function move(id, x, y)
{
  _.each(nodes_data, function(d) {
    if (d.id == id) {
      d.fx = x; d.fy = y;
      restart();
    }
  });

}

function reset()
{
  _.each(nodes_data, function(d) {
    d.fx = d.fy = null;
  });

  restart();
}


function updateSVGSize(width, height)
{
  d3.select("svg").attr("width", width).attr("height", height);
}