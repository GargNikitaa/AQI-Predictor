import 'package:flutter/material.dart';

class MyCardWidget extends StatelessWidget {
  bool isLoading;
  var composition; //map
  final List<String> impurities;
  var aqi;

  MyCardWidget({required this.impurities, this.composition, required this.isLoading, required this.aqi});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      height: 500,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.greenAccent[100],
        child: Padding(
          padding: const EdgeInsets.all(
            30,
          ),
          child: !isLoading ?  const Center(
            child: Text('Location Access Required!', style:TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Air Composition',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView(
                  children: List.generate(
                    impurities.length,
                        (index) {
                      return Column(
                        children: [
                          const Divider(height: 5, thickness: 3, color: Colors.green),
                          Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,

                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child:
                              Row(
                                children: [
                                  Text( impurities[index],
                                      style: const TextStyle(fontSize: 18.0,
                                        fontWeight: FontWeight.bold,)
                                  ),

                                  SizedBox(width: MediaQuery.of(context).size.width * 0.43 - impurities[index].length - composition[impurities[index]].toString().length),
                                  Text(
                                      !composition.containsKey(impurities[index]) ? 'NULL' : '${composition[impurities[index]]}g',
                                      style: const TextStyle(fontSize: 18.0,
                                      )
                                  ),
                                ],
                              ),
                           ),
                          ),
                          //SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}