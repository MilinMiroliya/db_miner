import 'package:db_miner/controller/quotes_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuotesListScreen extends StatefulWidget {
  const QuotesListScreen({super.key});

  @override
  State<QuotesListScreen> createState() => _QuotesListScreenState();
}

class _QuotesListScreenState extends State<QuotesListScreen> {
  @override
  void initState() {
    super.initState();
    var controller = Get.put(QuotesController());
    controller.fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: QuotesController(),
      builder: (QuotesController controller) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                controller.fetchQuotes();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
          backgroundColor: Colors.white,
          title: const Text('Random Quotes App'),
        ),
        body: Center(
          child: controller.quotes.isEmpty
              ? const CircularProgressIndicator()
              : ListView.builder(
                  itemCount: controller.quotes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.quotes[index].text,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  controller.quotes[index].author,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  controller.quotes[index].category
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
