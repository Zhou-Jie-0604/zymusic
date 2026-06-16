package com.zjlymusic.service;

import com.zjlymusic.entity.Music;
import com.zjlymusic.entity.Post;

import java.util.ArrayList;
import java.util.List;

public class SearchService {
    private MusicService musicService = new MusicService();
    private PostService postService = new PostService();
    
    public List<Music> searchMusic(String keyword) {
        return musicService.searchMusic(keyword);
    }
    
    public List<Object> searchAll(String keyword) {
        List<Object> results = new ArrayList<>();
        List<Music> musics = musicService.searchMusic(keyword);
        results.addAll(musics);
        return results;
    }
}