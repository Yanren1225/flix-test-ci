package com.ifreedomer.flix.android_filepicker;

import java.util.HashMap;

public class AndroidFileInfo {

    final String path;
    final String name;
    final String uri;
    final long size;

    public AndroidFileInfo(String path, String name, String uri, long size) {
        this.path = path;
        this.name = name;
        this.size = size;
        this.uri = uri;
    }

    public static class Builder {

        private String path;
        private String name;
        private String uri;
        private long size;

        public Builder withPath(String path){
            this.path = path;
            return this;
        }

        public Builder withName(String name){
            this.name = name;
            return this;
        }

        public Builder withSize(long size){
            this.size = size;
            return this;
        }


        public Builder withUri(String uri){
            this.uri = uri;
            return this;
        }

        public AndroidFileInfo build() {
            return new AndroidFileInfo(this.path, this.name, this.uri, this.size);
        }
    }


    public HashMap<String, Object> toMap() {
        final HashMap<String, Object> data = new HashMap<>();
        data.put("path", path);
        data.put("name", name);
        data.put("size", size);
        data.put("uri", uri);
        return data;
    }
}
