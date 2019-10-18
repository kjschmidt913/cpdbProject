dataset = {
    "children": [{
        "member_id": "Alabama",
        "percentile": 99,
        "noc": 100
    },
    {
        "member_id": "Alaska",
        "percentile": 88,
        "noc": 70
    },
    {
        "member_id": "Arizona",
        "percentile": 77,
        "noc": 56
    },
    {
        "member_id": "Arkansas",
        "percentile": 76,
        "noc": 88
    },
    {
        "member_id": "California",
        "percentile": 89,
        "noc": 60
    },
    {
        "member_id": "Colorado",
        "percentile": 20,
        "noc": 5
    },
    {
        "member_id": "Connecticut",
        "percentile": 20,
        "noc": 4
    },
    {
        "member_id": "Delaware",
        "percentile": 70,
        "noc": 17
    },
    {
        "member_id": "District of Columbia",
        "percentile": 98,
        "noc": 67
    },
    {
        "member_id": "Florida",
        "percentile": 79,
        "noc": 134
    },
    {
        "member_id": "Georgia",
        "percentile": 68,
        "noc": 67
    },
    {
        "member_id": "Hawaii",
        "percentile": 66,
        "noc": 89
    },
    {
        "member_id": "Idaho",
        "percentile": 57,
        "noc": 56
    },
    {
        "member_id": "Illinois",
        "percentile": 54,
        "noc": 45
    },
    {
        "member_id": "Indiana",
        "percentile": 76,
        "noc": 67
    },
    {
        "member_id": "Iowa",
        "percentile": 44,
        "noc": 68
    },
    {
        "member_id": "Kansas",
        "percentile": 88,
        "noc": 67
    },
    {
        "member_id": "Kentucky",
        "percentile": 98,
        "noc": 134
    },
    {
        "member_id": "Louisiana",
        "percentile": 32,
        "noc": 13
    },
    {
        "member_id": "Maine",
        "percentile": 23,
        "noc": 56
    },
    {
        "member_id": "Maryland",
        "percentile": 67,
        "noc": 78
    },
    {
        "member_id": "Massachusetts",
        "percentile": 12,
        "noc": 9
    },
    {
        "member_id": "Michigan",
        "percentile": 77,
        "noc": 88
    },
    {
        "member_id": "Minnesota",
        "percentile": 45,
        "noc": 45
    },
    {
        "member_id": "Mississippi",
        "percentile": 99,
        "noc": 134
    },
    {
        "member_id": "Missouri",
        "percentile": 34,
        "noc": 37
    },
    {
        "member_id": "Montana",
        "percentile": 66,
        "noc": 24
    },
    {
        "member_id": "Nebraska",
        "percentile": 88,
        "noc": 67
    },
    {
        "member_id": "Nevada",
        "percentile": 33,
        "noc": 14
    },
    {
        "member_id": "New Hampshire",
        "percentile": 14,
        "noc": 19
    },
    {
        "member_id": "New Jersey",
        "percentile": 88,
        "noc": 90
    },
    {
        "member_id": "New Mexico",
        "percentile": 90,
        "noc": 100
    }
    ]
};


var toolTip = d3.select("body").append("div")
    .attr("class", "tool-tip")
    .style("opacity", 0);

var diameter = 900;
var color = d3.scaleOrdinal(d3.schemeCategory20b);

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
        var percentile = "Percentile: " + d.data.percentile.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,') +
            "<br>" + "Number of Complaints: " + d.data.noc
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

// node.append("title")
//     .text(function (d) {
//         return d.member_id;
//     });

node.append("circle")
    .attr("r", function (d) {
        return d.r;
    })
    .style("fill", function (d, i) {
        return color(i);
    });

// node.append("text")
//     .attr("dy", ".2em")
//     .style("text-anchor", "middle")
//     .text(function (d) {
//         return d.data.member_id;
//     })
//     .attr("font-size", function (d) {
//         return d.r / 5;
//     })
//     .attr("fill", "white");

node.append("text")
    .attr("dy", "1.3em")
    .style("text-anchor", "middle")
    .attr("font-size", function (d) {
        return d.r / 5;
    })
    .attr("fill", "white");

d3.select(self.frameElement)
    .style("height", diameter + "px");