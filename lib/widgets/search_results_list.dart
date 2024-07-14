import 'package:flutter/material.dart';

class SearchResultsList extends StatelessWidget {
  final List<dynamic> searchResults;
  final bool isLoading;
  final Function(dynamic) onResultTapped;

  const SearchResultsList({
    super.key,
    required this.searchResults,
    required this.isLoading,
    required this.onResultTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text('No results found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final result = searchResults[index];
              return Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    title: Text(
                      result['display_name'].split(',')[0],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      result['display_name']
                          .split(',')
                          .sublist(1)
                          .join(',')
                          .trim(),
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onResultTapped(result),
                  ),
                  if (index < searchResults.length - 1)
                    const Divider(height: 1, color: Colors.grey),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}