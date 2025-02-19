/*
* Copyright (C) 2018  Calo001 <calo_lrc@hotmail.com>
* 
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero General Public License as published
* by the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero General Public License for more details.
* 
* You should have received a copy of the GNU Affero General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
* 
*/

using App.Widgets;
using App.Connection;
using App.Models;
using App.Connection;
using App.Configs;
using App.Enums;

namespace App.Views {

    /**
     * The {@code PhotosView} class.
     *
     * @since 1.0.0
     */
    public class PhotosView : Gtk.FlowBox {
        /**
         * Constructs a new {@code PhotosView} object.
         */
        public string filtermodeview { get; set; }
        public signal void applying_filter ();

        private unowned List<Photo?> photos;

        public PhotosView () {
            this.margin_end = 10;
            this.margin_start = 10;
            this.set_selection_mode(Gtk.SelectionMode.NONE);
            this.activate_on_single_click = false;
            this.homogeneous = false;
            this.orientation = Gtk.Orientation.HORIZONTAL;

            App.Application.settings.bind ("filter-mode", this, "filtermodeview", GLib.SettingsBindFlags.DEFAULT);
            this.bind_property ("filtermodeview", App.Configs.Settings.get_instance (), "filter-mode");

            this.notify["filtermodeview"].connect (() => {
                updateVisibility ();
            });

            this.child_activated.connect( (child)=>{
                var card = (CardPhotoView) child.get_child();
                card.popup.set_visible (true);
            });
        }

        /********************************************
           Method to set visibility to childflowbox
        ********************************************/
        private void updateVisibility () {
            forall ( ( child ) => {
                var flowboxchild = ((Gtk.FlowBoxChild) child).get_child();
                var photo_view_size = ((CardPhotoView) flowboxchild).size();
                applyVisibility (flowboxchild, photo_view_size);
            });
            applying_filter ();
        }

        private void applyVisibility (Gtk.Widget flowb, string size) {
            switch (filtermodeview) {
                case Constants.LANDSCAPE:
                    (size == Constants.LANDSCAPE) ? 
                        flowb.get_parent ().visible = true : flowb.get_parent ().visible = false;
                    break;
                case Constants.PORTRAIT:
                    (size == Constants.PORTRAIT) ? 
                        flowb.get_parent ().visible = true : flowb.get_parent ().visible = false;
                    break;
                default:
                    flowb.get_parent ().visible = true;
                    break;
            }
        }

        /********************************************
           Method to insert new photos from a list
        ********************************************/
        public void insert_cards (List<Photo?> photos, bool sort = true, TypeCard typeCard = NORMAL) {
            this.photos = photos;
            if (sort) this.photos.sort(compare);

            foreach (var photo in this.photos) {
                var card = new CardPhotoView (photo, typeCard);
                this.add(card);
                card.show_all();
            }
            updateVisibility ();
        }

        public void clean_list () {
            this.@foreach ( (widget) => {
                widget.destroy();
            });
        }

        CompareFunc<Photo?> compare = (a, b) => {
            double c = (int) a.width / (int) a.height;
            double d = (int) b.width / (int) b.height;
            return (int) (c > d) - (int) (c < d);
        };
    }
}
