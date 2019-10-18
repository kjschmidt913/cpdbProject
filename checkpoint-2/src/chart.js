var data = {
    [{
        "name": "A1",
        "children": [
            {
                "name": "B1",
                "children": [
                    {
                        "name": "C1",
                        "value": 100
                    },
                    {
                        "name": "C2",
                        "value": 300
                    },
                    {
                        "name": "C3",
                        "value": 200
                    }
                ]
            },
            {
                "name": "B2",
                "value": 200
            }
        ]
    }]
};

var packLayout = d3.pack()
    .size([300, 300])
    .padding(10)

var rootNode = d3.hierarchy(data)

rootNode.sum(function (d) {
    return d.value;
});

packLayout(rootNode);

d3.select('svg g')
    .selectAll('circle')
    .data(rootNode.descendants())
    .enter()
    .append('circle')
    .attr('cx', function (d) { return d.x; })
    .attr('cy', function (d) { return d.y; })
    .attr('r', function (d) { return d.r; })


