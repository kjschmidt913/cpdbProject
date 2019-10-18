dataset = {
    "children": [{
        "unit_id": "Alabama",
        "percentile": 99,
        "noc": 100,
        "supervisor_percentile": 55
    },
    {
        "unit_id": "Alaska",
        "percentile": 88,
        "noc": 70,
        "supervisor_percentile": 89
    },
    {
        "unit_id": "Arizona",
        "percentile": 77,
        "noc": 56,
        "supervisor_percentile": 45
    },
    {
        "unit_id": "Arkansas",
        "percentile": 76,
        "noc": 88,
        "supervisor_percentile": 90
    },
    {
        "unit_id": "California",
        "percentile": 89,
        "noc": 60,
        "supervisor_percentile": 78
    },
    {
        "unit_id": "Colorado",
        "percentile": 20,
        "noc": 5,
        "supervisor_percentile": 30
    },
    {
        "unit_id": "Connecticut",
        "percentile": 20,
        "noc": 4,
        "supervisor_percentile": 99
    },
    {
        "unit_id": "Delaware",
        "percentile": 70,
        "noc": 17,
        "supervisor_percentile": 80
    },
    {
        "unit_id": "District of Columbia",
        "percentile": 98,
        "noc": 67,
        "supervisor_percentile": 46
    },
    {
        "unit_id": "Florida",
        "percentile": 79,
        "noc": 134,
        "supervisor_percentile": 87
    },
    {
        "unit_id": "Georgia",
        "percentile": 68,
        "noc": 67,
        "supervisor_percentile": 93
    },
    {
        "unit_id": "Hawaii",
        "percentile": 66,
        "noc": 89,
        "supervisor_percentile": 88
    },
    {
        "unit_id": "Idaho",
        "percentile": 57,
        "noc": 56,
        "supervisor_percentile": 78
    },
    {
        "unit_id": "Illinois",
        "percentile": 54,
        "noc": 45,
        "supervisor_percentile": 34
    },
    {
        "unit_id": "Indiana",
        "percentile": 76,
        "noc": 67,
        "supervisor_percentile": 82
    },
    {
        "unit_id": "Iowa",
        "percentile": 44,
        "noc": 68,
        "supervisor_percentile": 76
    },
    {
        "unit_id": "Kansas",
        "percentile": 88,
        "noc": 67,
        "supervisor_percentile": 96
    },
    {
        "unit_id": "Kentucky",
        "percentile": 98,
        "noc": 134,
        "supervisor_percentile": 99
    },
    {
        "unit_id": "Louisiana",
        "percentile": 32,
        "noc": 13,
        "supervisor_percentile": 23
    },
    {
        "unit_id": "Maine",
        "percentile": 23,
        "noc": 56,
        "supervisor_percentile": 12
    },
    {
        "unit_id": "Maryland",
        "percentile": 67,
        "noc": 78,
        "supervisor_percentile": 47
    },
    {
        "unit_id": "Massachusetts",
        "percentile": 12,
        "noc": 9,
        "supervisor_percentile": 79
    },
    {
        "unit_id": "Michigan",
        "percentile": 77,
        "noc": 88,
        "supervisor_percentile": 54
    },
    {
        "unit_id": "Minnesota",
        "percentile": 45,
        "noc": 45,
        "supervisor_percentile": 34
    },
    {
        "unit_id": "Mississippi",
        "percentile": 99,
        "noc": 134,
        "supervisor_percentile": 33
    },
    {
        "unit_id": "Missouri",
        "percentile": 34,
        "noc": 37,
        "supervisor_percentile": 67
    },
    {
        "unit_id": "Montana",
        "percentile": 66,
        "noc": 24,
        "supervisor_percentile": 65
    },
    {
        "unit_id": "Nebraska",
        "percentile": 88,
        "noc": 67,
        "supervisor_percentile": 66
    },
    {
        "unit_id": "Nevada",
        "percentile": 33,
        "noc": 14,
        "supervisor_percentile": 72
    },
    {
        "unit_id": "New Hampshire",
        "percentile": 14,
        "noc": 19,
        "supervisor_percentile": 45
    },
    {
        "unit_id": "New Jersey",
        "percentile": 88,
        "noc": 90,
        "supervisor_percentile": 33
    },
    {
        "unit_id": "New Mexico",
        "percentile": 90,
        "noc": 100,
        "supervisor_percentile": 55
    }
    ]
};


var toolTip = d3.select("body").append("div")
    .attr("class", "tool-tip")
    .style("opacity", 0);

var diameter = 900;
var color = ["#08306b", "#8B0000"];


//edited the responsive bar code to apply to bubble chart
default_height = 500;
default_ratio = diameter / default_height;

// Determine current size, which determines vars
function set_size() {
    current_width = window.innerWidth;
    current_height = window.innerHeight;
    current_ratio = current_width / current_height;
    // Check if height is limiting factor
    if (current_ratio > default_ratio) {
        diameter = 900;
        // Else width is limiting
    } else {
        diameter = 400;
    }
};
set_size();

var bubble = d3.pack(dataset)
    .size([diameter, diameter])
    .padding(.5);

var svg = d3.select("#bubble")
    .append("svg")
    .attr("width", diameter)
    .attr("height", diameter)
    .attr("class", "bubble");

var nodes = d3.hierarchy(dataset)
    .sum(function (d) {
        return d.percentile;
    });


var node = svg.selectAll(".node")
    .data(bubble(nodes).descendants())
    .enter()
    .filter(function (d) {
        return !d.children
    })
    .append("g")
    .on('mouseover', function (d, i) {
        d3.select(this).transition()
            .duration('100')
            .attr('opacity', '.8');
        toolTip.transition()
            .duration(50)
            .style("opacity", 1);
        var percentile = "Unit Percentile: " + d.data.percentile.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,') +
            "<br>" + "Number of Complaints: " + d.data.noc +
            "<br>" + "Supervisor's Percentile: " + d.data.supervisor_percentile
        toolTip.html(percentile)
            .style("left", (d3.event.pageX + 10) + "px")
            .style("top", (d3.event.pageY - 15) + "px");
    })
    .on('mouseout', function (d, i) {
        d3.select(this).transition()
            .duration('100')
            .attr('opacity', '1');
        toolTip.transition()
            .duration(50)
            .style("opacity", 0);
    })
    .attr("class", "node")
    .attr("transform", function (d) {
        return "translate(" + d.x + "," + d.y + ")";
    });

node.append("circle")
    .attr("r", function (d) {
        return d.r;
    })
    .style("fill", function (d, i) {
        if(d.data.supervisor_percentile > 75){
            return color[1];
        } else{
            return color[0];
        }  
    });

node.append("text")
    .attr("dy", "1.3em")
    .style("text-anchor", "middle")
    .attr("font-size", function (d) {
        return d.r / 5;
    })
    .attr("fill", "white");

d3.select(self.frameElement)
    .style("height", diameter + "px");